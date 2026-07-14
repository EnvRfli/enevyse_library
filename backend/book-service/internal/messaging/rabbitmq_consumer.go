package messaging

import (
	"context"
	"encoding/json"
	"log"
	"os"
	"time"

	"book-service/domain"

	"github.com/google/uuid"
	amqp "github.com/rabbitmq/amqp091-go"
)

type BookingRequestMessage struct {
	TransactionID uuid.UUID `json:"transaction_id"`
	BookID        uuid.UUID `json:"book_id"`
	Timestamp     time.Time `json:"timestamp"`
}

type BookingReplyMessage struct {
	TransactionID uuid.UUID `json:"transaction_id"`
	Status        string    `json:"status"` // "SUCCESS" or "FAILED"
}

// ConsumeBookingRequests connects to RabbitMQ and listens for booking requests.
func ConsumeBookingRequests(bookRepo domain.BookRepository) {
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

	// Ensure queues exist
	requestQueue, err := ch.QueueDeclare(
		"booking_requests",
		true, false, false, false, nil,
	)
	if err != nil {
		log.Printf("Consumer failed to declare queue: %v", err)
		return
	}

	replyQueue, err := ch.QueueDeclare(
		"booking_replies",
		true, false, false, false, nil,
	)
	if err != nil {
		log.Printf("Consumer failed to declare reply queue: %v", err)
		return
	}

	msgs, err := ch.Consume(
		requestQueue.Name,
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

	log.Println(" [*] Waiting for booking_requests. To exit press CTRL+C")

	for d := range msgs {
		var req BookingRequestMessage
		if err := json.Unmarshal(d.Body, &req); err != nil {
			log.Printf("Error unmarshaling message: %v", err)
			continue
		}

		log.Printf(" [x] Received booking request for BookID: %s, TxID: %s", req.BookID, req.TransactionID)

		// Check book availability
		replyStatus := "FAILED"
		book, err := bookRepo.FindByID(req.BookID)
		if err != nil {
			log.Printf("Error finding book: %v", err)
		} else if book != nil && book.AvailableCopies > 0 {
			// Decrement copies
			if err := bookRepo.UpdateAvailableCopies(book.ID, -1); err == nil {
				replyStatus = "SUCCESS"
			} else {
				log.Printf("Error updating available copies: %v", err)
			}
		} else {
			log.Printf("Book not found or no available copies for BookID: %s", req.BookID)
		}

		// Publish reply
		reply := BookingReplyMessage{
			TransactionID: req.TransactionID,
			Status:        replyStatus,
		}
		
		body, err := json.Marshal(reply)
		if err != nil {
			log.Printf("Error marshaling reply: %v", err)
			continue
		}

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		err = ch.PublishWithContext(ctx,
			"",              // exchange
			replyQueue.Name, // routing key
			false,           // mandatory
			false,           // immediate
			amqp.Publishing{
				ContentType: "application/json",
				Body:        body,
			})
		cancel()

		if err != nil {
			log.Printf("Failed to publish a reply: %v", err)
		} else {
			log.Printf(" [x] Sent booking reply for TxID: %s with Status: %s", reply.TransactionID, reply.Status)
		}
	}
}

type BookReturnMessage struct {
	BookID uuid.UUID `json:"book_id"`
	Qty    int       `json:"qty"`
}

// ConsumeReturnEvents connects to RabbitMQ and listens for book return events.
func ConsumeReturnEvents(bookRepo domain.BookRepository) {
	rabbitURL := os.Getenv("RABBITMQ_URL")
	if rabbitURL == "" {
		rabbitURL = "amqp://guest:guest@localhost:5672/"
	}

	conn, err := amqp.Dial(rabbitURL)
	if err != nil {
		log.Printf("ReturnConsumer failed to connect to RabbitMQ: %v", err)
		return
	}
	defer conn.Close()

	ch, err := conn.Channel()
	if err != nil {
		log.Printf("ReturnConsumer failed to open a channel: %v", err)
		return
	}
	defer ch.Close()

	// Ensure queue exists
	returnQueue, err := ch.QueueDeclare(
		"book_return_events",
		true, false, false, false, nil,
	)
	if err != nil {
		log.Printf("ReturnConsumer failed to declare queue: %v", err)
		return
	}

	msgs, err := ch.Consume(
		returnQueue.Name,
		"",    // consumer
		true,  // auto-ack
		false, // exclusive
		false, // no-local
		false, // no-wait
		nil,   // args
	)
	if err != nil {
		log.Printf("ReturnConsumer failed to register a consumer: %v", err)
		return
	}

	log.Println(" [*] Waiting for book_return_events. To exit press CTRL+C")

	for d := range msgs {
		var req BookReturnMessage
		if err := json.Unmarshal(d.Body, &req); err != nil {
			log.Printf("Error unmarshaling return message: %v", err)
			continue
		}

		log.Printf(" [x] Received return event for BookID: %s, Qty: %d", req.BookID, req.Qty)

		// Increment available copies
		if err := bookRepo.UpdateAvailableCopies(req.BookID, req.Qty); err != nil {
			log.Printf("Error updating available copies for return: %v", err)
		} else {
			log.Printf(" [x] Successfully incremented copies for BookID: %s", req.BookID)
		}
	}
}
