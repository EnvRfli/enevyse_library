package usecase

import (
	"errors"
	"fmt"
	"time"
	"transaction-service/domain"
	"transaction-service/internal/messaging"

	"github.com/google/uuid"
)

type transactionUsecase struct {
	txRepo domain.TransactionRepository
}

func NewTransactionUsecase(repo domain.TransactionRepository) domain.TransactionUsecase {
	return &transactionUsecase{txRepo: repo}
}

func (u *transactionUsecase) BorrowBook(userID uint, req *domain.BorrowRequest) (*domain.Transaction, error) {
	// 1. Check Max 3 Books Limit
	activeCount, err := u.txRepo.CountActiveTransactions(userID)
	if err != nil {
		return nil, errors.New("failed to check active transactions")
	}
	if activeCount >= 3 {
		return nil, errors.New("You can only borrow up to 3 books at a time.")
	}

	todayCount, err := u.txRepo.GetTodayCount()
	if err != nil {
		return nil, errors.New("failed to generate borrow ID")
	}

	// Generate custom BorrowID: #LB-YYYYMMDD-XXX
	dateStr := time.Now().Format("20060102")
	sequence := fmt.Sprintf("%03d", todayCount+1)
	borrowID := fmt.Sprintf("#LB-%s-%s", dateStr, sequence)

	now := time.Now()
	// Default business rules for dates
	pickupDeadline := now.Add(2 * 24 * time.Hour) // 2 days from now
	dueDate := now.Add(7 * 24 * time.Hour)        // 7 days from now

	tx := &domain.Transaction{
		BorrowID:       borrowID,
		UserID:         userID,
		BookID:         req.BookID,
		PickupLocation: req.PickupLocation,
		PickupDeadline: pickupDeadline,
		BorrowDate:     now,
		DueDate:        dueDate,
		Status:         domain.StatusPending,
	}

	if err := u.txRepo.Create(tx); err != nil {
		return nil, errors.New("failed to create transaction")
	}

	// Publish message to RabbitMQ for Saga Pattern (e.g., to notify Book Service to check/reserve stock)
	if err := messaging.PublishBookingRequest(tx.BookID, tx.ID); err != nil {
		// Log the error but don't fail the transaction creation,
		// or handle it with an outbox pattern in a production scenario.
		fmt.Printf("Warning: Failed to publish booking request to RabbitMQ: %v\n", err)
	}

	return tx, nil
}

func (u *transactionUsecase) GetMyTransactions(userID uint) ([]domain.Transaction, error) {
	return u.txRepo.FindByUserID(userID)
}

func (u *transactionUsecase) GetTransactionByID(id uuid.UUID) (*domain.Transaction, error) {
	tx, err := u.txRepo.FindByID(id)
	if err != nil {
		return nil, err
	}
	if tx == nil {
		return nil, errors.New("transaction not found")
	}
	return tx, nil
}

func (u *transactionUsecase) PickupBook(id uuid.UUID) (*domain.Transaction, error) {
	tx, err := u.txRepo.FindByID(id)
	if err != nil {
		return nil, err
	}
	if tx == nil {
		return nil, errors.New("transaction not found")
	}

	if tx.Status != domain.StatusApproved {
		return nil, errors.New("only approved transactions can be picked up")
	}

	now := time.Now()
	tx.Status = domain.StatusBorrowing
	tx.PickedUpAt = &now
	tx.UpdatedAt = now

	if err := u.txRepo.Update(tx); err != nil {
		return nil, errors.New("failed to update transaction")
	}

	return tx, nil
}

func (u *transactionUsecase) ExtendBorrow(userID uint, id uuid.UUID) (*domain.Transaction, error) {
	tx, err := u.txRepo.FindByID(id)
	if err != nil {
		return nil, err
	}
	if tx == nil {
		return nil, errors.New("transaction not found")
	}

	if tx.UserID != userID {
		return nil, errors.New("unauthorized to extend this transaction")
	}

	if tx.Status != domain.StatusBorrowing {
		return nil, errors.New("only active borrowing transactions can be extended")
	}

	tx.DueDate = tx.DueDate.Add(7 * 24 * time.Hour)
	tx.UpdatedAt = time.Now()

	if err := u.txRepo.Update(tx); err != nil {
		return nil, errors.New("failed to update transaction")
	}

	return tx, nil
}

func (u *transactionUsecase) ReturnBook(id uuid.UUID) (*domain.Transaction, error) {
	tx, err := u.txRepo.FindByID(id)
	if err != nil {
		return nil, err
	}
	if tx == nil {
		return nil, errors.New("transaction not found")
	}

	if tx.Status != domain.StatusBorrowing {
		return nil, errors.New("only active borrowing transactions can be returned")
	}

	now := time.Now()
	tx.Status = domain.StatusReturned
	tx.ReturnedAt = &now
	tx.UpdatedAt = now

	if err := u.txRepo.Update(tx); err != nil {
		return nil, errors.New("failed to update transaction")
	}

	// Publish return event to RabbitMQ
	if err := messaging.PublishReturnEvent(tx.BookID, 1); err != nil {
		fmt.Printf("Warning: Failed to publish return event to RabbitMQ: %v\n", err)
	}

	return tx, nil
}

func (u *transactionUsecase) ProcessScan(borrowID string) (*domain.Transaction, error) {
	tx, err := u.txRepo.FindByBorrowID(borrowID)
	if err != nil {
		return nil, err
	}
	if tx == nil {
		return nil, errors.New("transaction not found")
	}

	if tx.Status == domain.StatusApproved {
		return u.PickupBook(tx.ID)
	} else if tx.Status == domain.StatusBorrowing {
		return u.ReturnBook(tx.ID)
	}

	return nil, errors.New("invalid transaction status for scanning")
}
