package domain

import (
	"time"

	"github.com/google/uuid"
)

const (
	StatusPending   = "PENDING"
	StatusApproved  = "APPROVED"
	StatusBorrowing = "BORROWING"
	StatusReturned  = "RETURNED"
	StatusRejected  = "REJECTED"
)

// Transaction represents a borrowing transaction.
type Transaction struct {
	ID             uuid.UUID  `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	BorrowID       string     `gorm:"uniqueIndex;not null" json:"borrow_id"` // Format: #LB-YYYYMMDD-XXX
	UserID         uint       `gorm:"not null" json:"user_id"`
	BookID         uuid.UUID  `gorm:"type:uuid;not null" json:"book_id"`
	PickupLocation string     `gorm:"not null" json:"pickup_location"`
	PickupDeadline time.Time  `gorm:"not null" json:"pickup_deadline"`
	BorrowDate     time.Time  `gorm:"not null" json:"borrow_date"`
	DueDate        time.Time  `gorm:"not null" json:"due_date"`
	Status         string     `gorm:"not null;default:'PENDING'" json:"status"`
	CreatedAt      time.Time  `json:"created_at"` // Maps to "Request Submitted" timeline
	ApprovedAt     *time.Time `json:"approved_at"` // Nullable, maps to "Approved" timeline
	PickedUpAt     *time.Time `json:"picked_up_at"` // Nullable, maps to "Book Picked Up" timeline
	ReturnedAt     *time.Time `json:"returned_at"` // Nullable, maps to "Returned" timeline
	UpdatedAt      time.Time  `json:"updated_at"`
}

// BorrowRequest is the payload for creating a new transaction.
type BorrowRequest struct {
	BookID         uuid.UUID `json:"book_id" validate:"required"`
	PickupLocation string    `json:"pickup_location" validate:"required"`
}

// TransactionRepository defines the contract for transaction database operations.
type TransactionRepository interface {
	Create(tx *Transaction) error
	UpdateStatus(id uuid.UUID, status string, timestampField *time.Time) error
	FindByUserID(userID uint) ([]Transaction, error)
	FindByID(id uuid.UUID) (*Transaction, error)
	FindByBorrowID(borrowID string) (*Transaction, error)
	GetTodayCount() (int64, error)
	CountActiveTransactions(userID uint) (int64, error)
	Update(tx *Transaction) error
}

// TransactionUsecase defines the contract for transaction business logic.
type TransactionUsecase interface {
	BorrowBook(userID uint, req *BorrowRequest) (*Transaction, error)
	GetMyTransactions(userID uint) ([]Transaction, error)
	GetTransactionByID(id uuid.UUID) (*Transaction, error)
	PickupBook(id uuid.UUID) (*Transaction, error)
	ExtendBorrow(userID uint, id uuid.UUID) (*Transaction, error)
	ReturnBook(id uuid.UUID) (*Transaction, error)
	ProcessScan(borrowID string) (*Transaction, error)
}
