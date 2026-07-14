package messaging

import (
	"encoding/json"
	"log"
	"os"
	"time"

	"transaction-service/domain"

	"github.com/google/uuid"
	amqp "github.com/rabbitmq/amqp091-go"
)

type BookingReplyMessage struct {
	TransactionID uuid.UUID `json:"transaction_id"`
	Status        string    `json:"status"` // "SUCCESS" or "FAILED"
}

// ConsumeBookingReplies connects to RabbitMQ and listens for booking replies.
func ConsumeBookingReplies(txRepo domain.TransactionRepository) {
	rabbitURL := os.Getenv("RABBITMQ_URL")
	if rabbitURL == "" {
		rabbitURL = "amqp://guest:guest@localhost:5672/"
	}

	conn, err := amqp.Dial(rabbitURL)
	if err != nil {
		log.Printf("Consumer failed to connect to RabbitMQ: %v", err)
		return
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		log.Printf("Consumer failed to open a channel: %v", err)
		return
	}
	defer ch.Close()

	// Ensure queue exists
	replyQueue, err := ch.QueueDeclare(
		"booking_replies",
		true, false, false, false, nil,
	)
	if err != nil {
		log.Printf("Consumer failed to declare reply queue: %v", err)
		return
	}

	msgs, err := ch.Consume(
		replyQueue.Name,
		"",    // consumer
		true,  // auto-ack
		false, // exclusive
		false, // no-local
		false, // no-wait
		nil,   // args
	)
	if err != nil {
		log.Printf("Consumer failed to register a consumer: %v", err)
		return
	}

	log.Println(" [*] Waiting for booking_replies. To exit press CTRL+C")

	for d := range msgs {
		var reply BookingReplyMessage
		if err := json.Unmarshal(d.Body, &reply); err != nil {
			log.Printf("Error unmarshaling message: %v", err)
			continue
		}

		log.Printf(" [x] Received booking reply for TxID: %s, Status: %s", reply.TransactionID, reply.Status)

		now := time.Now()
		var newStatus string
		var timestampField *time.Time

		if reply.Status == "SUCCESS" {
			newStatus = domain.StatusApproved
			timestampField = &now
		} else {
			newStatus = domain.StatusRejected
			// Optionally update a rejected_at timestamp if it exists, otherwise pass nil
			timestampField = nil
		}

		if err := txRepo.UpdateStatus(reply.TransactionID, newStatus, timestampField); err != nil {
			log.Printf("Failed to update transaction status: %v", err)
		} else {
			log.Printf(" [x] Successfully updated TxID: %s to Status: %s", reply.TransactionID, newStatus)
		}
	}
}
