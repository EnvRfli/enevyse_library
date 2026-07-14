package usecase

import (
	"errors"
	"book-service/domain"

	"github.com/google/uuid"
)

type bookUsecase struct {
	bookRepo domain.BookRepository
}

func NewBookUsecase(repo domain.BookRepository) domain.BookUsecase {
	return &bookUsecase{bookRepo: repo}
}

func (u *bookUsecase) GetAllBooks(filter domain.BookFilter) ([]domain.Book, error) {
	return u.bookRepo.FindAll(filter)
}

func (u *bookUsecase) GetBookByID(id uuid.UUID) (*domain.Book, error) {
	book, err := u.bookRepo.FindByID(id)
	if err != nil {
		return nil, err
	}
	if book == nil {
		return nil, errors.New("book not found")
	}
	return book, nil
}

func (u *bookUsecase) ToggleFavorite(userID uint, bookID uuid.UUID) (bool, error) {
	// check if book exists first
	book, err := u.bookRepo.FindByID(bookID)
	if err != nil {
		return false, err
	}
	if book == nil {
		return false, errors.New("book not found")
	}

	return u.bookRepo.ToggleFavorite(userID, bookID)
}

func (u *bookUsecase) GetUserFavorites(userID uint) ([]domain.Book, error) {
	return u.bookRepo.FindFavoritesByUserID(userID)
}
