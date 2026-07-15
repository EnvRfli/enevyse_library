package repository

import (
	"errors"
	"book-service/domain"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type bookRepository struct {
	db *gorm.DB
}

func NewBookRepository(db *gorm.DB) domain.BookRepository {
	return &bookRepository{db: db}
}

func (r *bookRepository) FindAll(filter domain.BookFilter) ([]domain.Book, error) {
	var books []domain.Book
	query := r.db

	if filter.Title != "" {
		query = query.Where("title ILIKE ?", "%"+filter.Title+"%")
	}
	if filter.Category != "" {
		// using array contains operator for PostgreSQL since category is now an array
		query = query.Where("? = ANY(category)", filter.Category)
	}
	if filter.MinRating > 0 {
		query = query.Where("ratings >= ?", filter.MinRating)
	}
	if filter.Language != "" {
		query = query.Where("language ILIKE ?", filter.Language)
	}

	result := query.Find(&books)
	if result.Error != nil {
		return nil, result.Error
	}
	return books, nil
}

func (r *bookRepository) FindByID(id uuid.UUID) (*domain.Book, error) {
	var book domain.Book
	result := r.db.First(&book, id)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &book, nil
}

func (r *bookRepository) UpdateAvailableCopies(id uuid.UUID, delta int) error {
	return r.db.Model(&domain.Book{}).Where("id = ?", id).
		Update("available_copies", gorm.Expr("available_copies + ?", delta)).Error
}

func (r *bookRepository) ToggleFavorite(userID uint, bookID uuid.UUID) (bool, error) {
	var fav domain.FavoriteBook
	result := r.db.Where("user_id = ? AND book_id = ?", userID, bookID).First(&fav)

	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			// Record not found, so add it
			newFav := domain.FavoriteBook{UserID: userID, BookID: bookID}
			if err := r.db.Create(&newFav).Error; err != nil {
				return false, err
			}
			return true, nil // Returns true meaning "favorited"
		}
		return false, result.Error
	}

	// Record found, so delete it
	if err := r.db.Delete(&fav).Error; err != nil {
		return false, err
	}
	return false, nil // Returns false meaning "unfavorited"
}

func (r *bookRepository) FindFavoritesByUserID(userID uint) ([]domain.Book, error) {
	var books []domain.Book
	err := r.db.Joins("JOIN favorite_books ON favorite_books.book_id = books.id").
		Where("favorite_books.user_id = ?", userID).
		Find(&books).Error
	if err != nil {
		return nil, err
	}
	return books, nil
}

func (r *bookRepository) Create(book *domain.Book) error {
	return r.db.Create(book).Error
}

func (r *bookRepository) Update(book *domain.Book) error {
	return r.db.Save(book).Error
}

func (r *bookRepository) Delete(id uuid.UUID) error {
	result := r.db.Delete(&domain.Book{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("book not found")
	}
	return nil
}

func (r *bookRepository) UpdateCover(id uuid.UUID, coverURL string) error {
	result := r.db.Model(&domain.Book{}).Where("id = ?", id).Update("cover_url", coverURL)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("book not found")
	}
	return nil
}
