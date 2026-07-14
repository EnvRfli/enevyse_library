package repository

import (
	"errors"
	"identity-service/domain"

	"gorm.io/gorm"
)

// userRepository adalah implementasi dari domain.UserRepository.
type userRepository struct {
	db *gorm.DB
}

// NewUserRepository membuat instance baru dari userRepository.
func NewUserRepository(db *gorm.DB) domain.UserRepository {
	return &userRepository{db: db}
}

// Create menyimpan pengguna baru ke database.
func (r *userRepository) Create(user *domain.User) error {
	return r.db.Create(user).Error
}

// FindByEmail mencari pengguna berdasarkan email.
func (r *userRepository) FindByEmail(email string) (*domain.User, error) {
	var user domain.User
	result := r.db.Where("email = ?", email).First(&user)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &user, nil
}

// FindByID mencari pengguna berdasarkan ID.
func (r *userRepository) FindByID(id uint) (*domain.User, error) {
	var user domain.User
	result := r.db.First(&user, id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &user, nil
}

// Update menyimpan pembaruan entitas pengguna ke database.
func (r *userRepository) Update(user *domain.User) error {
	return r.db.Save(user).Error
}
