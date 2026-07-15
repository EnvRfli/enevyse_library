package usecase

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"
	
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

func (u *bookUsecase) CreateBook(book *domain.Book) error {
	// Initialize default values if needed
	if book.TotalCopies == 0 {
		book.TotalCopies = 1
	}
	if book.AvailableCopies == 0 {
		book.AvailableCopies = book.TotalCopies
	}
	return u.bookRepo.Create(book)
}

func (u *bookUsecase) UpdateBook(id uuid.UUID, book *domain.Book) error {
	existingBook, err := u.bookRepo.FindByID(id)
	if err != nil {
		return err
	}
	if existingBook == nil {
		return errors.New("book not found")
	}

	book.ID = id
	return u.bookRepo.Update(book)
}

func (u *bookUsecase) DeleteBook(id uuid.UUID) error {
	return u.bookRepo.Delete(id)
}

func (u *bookUsecase) UploadCoverImage(id uuid.UUID, fileData []byte, fileName string, contentType string) (string, error) {
	existingBook, err := u.bookRepo.FindByID(id)
	if err != nil {
		return "", err
	}
	if existingBook == nil {
		return "", errors.New("book not found")
	}

	supabaseURL := os.Getenv("SUPABASE_URL")
	supabaseKey := os.Getenv("SUPABASE_KEY")
	supabaseBucket := os.Getenv("SUPABASE_BUCKET")

	if supabaseURL == "" || supabaseKey == "" || supabaseBucket == "" {
		return "", errors.New("supabase credentials are not configured")
	}

	// Generate a unique filename using book ID
	ext := filepath.Ext(fileName)
	if ext == "" {
		ext = ".jpg" // Default extension
	}
	objectName := fmt.Sprintf("covers/%s%s", id.String(), ext)

	uploadURL := fmt.Sprintf("%s/storage/v1/object/%s/%s", supabaseURL, supabaseBucket, objectName)

	req, err := http.NewRequest("POST", uploadURL, bytes.NewReader(fileData))
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+supabaseKey)
	req.Header.Set("Content-Type", contentType)

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to upload image: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusCreated {
		bodyBytes, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("supabase upload failed with status %d: %s", resp.StatusCode, string(bodyBytes))
	}

	// Construct public URL
	publicURL := fmt.Sprintf("%s/storage/v1/object/public/%s/%s", supabaseURL, supabaseBucket, objectName)

	if err := u.bookRepo.UpdateCover(id, publicURL); err != nil {
		return "", fmt.Errorf("failed to update book cover in database: %w", err)
	}

	return publicURL, nil
}
