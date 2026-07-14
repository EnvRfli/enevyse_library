package domain

import (
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// Book represents a book entity in the system.
type Book struct {
	ID              uuid.UUID      `gorm:"type:uuid;default:gen_random_uuid();primaryKey" json:"id"`
	Title           string         `gorm:"not null" json:"title"`
	Author          string         `gorm:"not null" json:"author"`
	Publisher       string         `json:"publisher"`
	Published       time.Time      `json:"published"`
	Ratings         float64        `gorm:"default:0" json:"ratings"`
	CoverURL        string         `json:"cover_url"`
	Category        string         `json:"category"`
	Genre           string         `json:"genre"`
	Languages       pq.StringArray `gorm:"type:text[]" json:"languages"`
	TotalCopies     int            `gorm:"not null;default:1" json:"total_copies"`
	AvailableCopies int            `gorm:"not null;default:1" json:"available_copies"`
	Synopsis        string         `gorm:"type:text" json:"synopsis"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
}

// FavoriteBook represents a user's favorited book.
type FavoriteBook struct {
	UserID uint      `gorm:"primaryKey" json:"user_id"`
	BookID uuid.UUID `gorm:"type:uuid;primaryKey" json:"book_id"`
}

// BookFilter defines the filter parameters for searching books.
type BookFilter struct {
	Title     string
	Category  string
	MinRating float64
	Language  string
}

// BookRepository defines the contract for book database operations.
type BookRepository interface {
	FindAll(filter BookFilter) ([]Book, error)
	FindByID(id uuid.UUID) (*Book, error)
	UpdateAvailableCopies(id uuid.UUID, delta int) error
	ToggleFavorite(userID uint, bookID uuid.UUID) (bool, error)
	FindFavoritesByUserID(userID uint) ([]Book, error)
}

// BookUsecase defines the contract for book business logic.
type BookUsecase interface {
	GetAllBooks(filter BookFilter) ([]Book, error)
	GetBookByID(id uuid.UUID) (*Book, error)
	ToggleFavorite(userID uint, bookID uuid.UUID) (bool, error)
	GetUserFavorites(userID uint) ([]Book, error)
}
