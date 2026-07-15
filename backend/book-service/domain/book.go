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
	Category        pq.StringArray `gorm:"type:text[]" json:"categories"`
	Genre           pq.StringArray `gorm:"type:text[]" json:"genres"`
	Language        string         `json:"language"`
	TotalCopies     int            `gorm:"not null;default:1" json:"total_copies"`
	AvailableCopies int            `gorm:"not null;default:1" json:"available_copies"`
	TotalPages      int            `gorm:"default:0" json:"total_pages"`
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
	Category  string // We keep it string because frontend passes a single category to filter, or we can make it []string. But for backward compatibility with `GetAllBooks` we leave it as string to search within the array.
	MinRating float64
	Language  string
	SortBy    string
}

// BookRepository defines the contract for book database operations.
type BookRepository interface {
	FindAll(filter BookFilter) ([]Book, error)
	FindByID(id uuid.UUID) (*Book, error)
	UpdateAvailableCopies(id uuid.UUID, delta int) error
	ToggleFavorite(userID uint, bookID uuid.UUID) (bool, error)
	FindFavoritesByUserID(userID uint) ([]Book, error)
	Create(book *Book) error
	Update(book *Book) error
	Delete(id uuid.UUID) error
	UpdateCover(id uuid.UUID, coverURL string) error
}

// BookUsecase defines the contract for book business logic.
type BookUsecase interface {
	GetAllBooks(filter BookFilter) ([]Book, error)
	GetBookByID(id uuid.UUID) (*Book, error)
	ToggleFavorite(userID uint, bookID uuid.UUID) (bool, error)
	GetUserFavorites(userID uint) ([]Book, error)
	CreateBook(book *Book) error
	UpdateBook(id uuid.UUID, book *Book) error
	DeleteBook(id uuid.UUID) error
	UploadCoverImage(id uuid.UUID, fileData []byte, fileName string, contentType string) (string, error)
}
