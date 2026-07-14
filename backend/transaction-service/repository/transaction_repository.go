package repository

import (
	"errors"
	"time"
	"transaction-service/domain"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type transactionRepository struct {
	db *gorm.DB
}

func NewTransactionRepository(db *gorm.DB) domain.TransactionRepository {
	return &transactionRepository{db: db}
}

func (r *transactionRepository) Create(tx *domain.Transaction) error {
	return r.db.Create(tx).Error
}

func (r *transactionRepository) UpdateStatus(id uuid.UUID, status string, timestampField *time.Time) error {
	updates := map[string]interface{}{
		"status":     status,
		"updated_at": time.Now(),
	}

	// Update specific timestamp field based on status progression
	if timestampField != nil {
		switch status {
		case domain.StatusApproved:
			updates["approved_at"] = timestampField
		case domain.StatusBorrowing:
			updates["picked_up_at"] = timestampField
		case domain.StatusReturned:
			updates["returned_at"] = timestampField
		}
	}

	return r.db.Model(&domain.Transaction{}).Where("id = ?", id).Updates(updates).Error
}

func (r *transactionRepository) FindByUserID(userID uint) ([]domain.Transaction, error) {
	var transactions []domain.Transaction
	// Order by most recent first
	result := r.db.Where("user_id = ?", userID).Order("created_at desc").Find(&transactions)
	if result.Error != nil {
		return nil, result.Error
	}
	return transactions, nil
}

func (r *transactionRepository) FindByID(id uuid.UUID) (*domain.Transaction, error) {
	var transaction domain.Transaction
	result := r.db.First(&transaction, id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &transaction, nil
}

func (r *transactionRepository) GetTodayCount() (int64, error) {
	var count int64
	today := time.Now().Truncate(24 * time.Hour)
	tomorrow := today.Add(24 * time.Hour)
	
	result := r.db.Model(&domain.Transaction{}).
		Where("created_at >= ? AND created_at < ?", today, tomorrow).
		Count(&count)
		
	return count, result.Error
}

func (r *transactionRepository) CountActiveTransactions(userID uint) (int64, error) {
	var count int64
	result := r.db.Model(&domain.Transaction{}).
		Where("user_id = ? AND status IN ?", userID, []string{domain.StatusPending, domain.StatusApproved, domain.StatusBorrowing}).
		Count(&count)
	return count, result.Error
}

func (r *transactionRepository) Update(tx *domain.Transaction) error {
	return r.db.Save(tx).Error
}
