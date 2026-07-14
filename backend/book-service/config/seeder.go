package config

import (
	"log"
	"time"
	"book-service/domain"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

func SeedBooks(db *gorm.DB) {
	var count int64
	db.Model(&domain.Book{}).Count(&count)

	if count > 0 {
		log.Println("📚 Books table is not empty, skipping seeder")
		return
	}

	log.Println("🌱 Seeding books data...")

	books := []domain.Book{
		{
			ID:              uuid.New(),
			Title:           "The Go Programming Language",
			Author:          "Alan A. A. Donovan, Brian W. Kernighan",
			Publisher:       "Addison-Wesley Professional",
			Published:       time.Date(2015, 10, 26, 0, 0, 0, 0, time.UTC),
			Ratings:         4.8,
			CoverURL:        "https://via.placeholder.com/150",
			Category:        "Programming",
			Genre:           "Technology",
			Languages:       []string{"English"},
			TotalCopies:     10,
			AvailableCopies: 10,
			Synopsis:        "The Go Programming Language is the authoritative resource for any programmer who wants to learn Go.",
		},
		{
			ID:              uuid.New(),
			Title:           "Clean Code",
			Author:          "Robert C. Martin",
			Publisher:       "Prentice Hall",
			Published:       time.Date(2008, 8, 11, 0, 0, 0, 0, time.UTC),
			Ratings:         4.7,
			CoverURL:        "https://via.placeholder.com/150",
			Category:        "Programming",
			Genre:           "Technology",
			Languages:       []string{"English"},
			TotalCopies:     5,
			AvailableCopies: 5,
			Synopsis:        "Even bad code can function. But if code isn't clean, it can bring a development organization to its knees.",
		},
		{
			ID:              uuid.New(),
			Title:           "Design Patterns",
			Author:          "Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides",
			Publisher:       "Addison-Wesley Professional",
			Published:       time.Date(1994, 11, 10, 0, 0, 0, 0, time.UTC),
			Ratings:         4.6,
			CoverURL:        "https://via.placeholder.com/150",
			Category:        "Programming",
			Genre:           "Technology",
			Languages:       []string{"English"},
			TotalCopies:     7,
			AvailableCopies: 7,
			Synopsis:        "Capturing a wealth of experience about the design of object-oriented software.",
		},
		{
			ID:              uuid.New(),
			Title:           "The Pragmatic Programmer",
			Author:          "David Thomas, Andrew Hunt",
			Publisher:       "Addison-Wesley Professional",
			Published:       time.Date(1999, 10, 30, 0, 0, 0, 0, time.UTC),
			Ratings:         4.9,
			CoverURL:        "https://via.placeholder.com/150",
			Category:        "Programming",
			Genre:           "Technology",
			Languages:       []string{"English"},
			TotalCopies:     12,
			AvailableCopies: 12,
			Synopsis:        "The Pragmatic Programmer is one of those rare tech books you'll read, re-read, and read again over the years.",
		},
		{
			ID:              uuid.New(),
			Title:           "Introduction to Algorithms",
			Author:          "Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein",
			Publisher:       "MIT Press",
			Published:       time.Date(2009, 7, 31, 0, 0, 0, 0, time.UTC),
			Ratings:         4.5,
			CoverURL:        "https://via.placeholder.com/150",
			Category:        "Algorithms",
			Genre:           "Computer Science",
			Languages:       []string{"English"},
			TotalCopies:     3,
			AvailableCopies: 3,
			Synopsis:        "A comprehensive update of the leading algorithms text, with new material on matchings in bipartite graphs, online algorithms, machine learning, and other topics.",
		},
	}

	if err := db.Create(&books).Error; err != nil {
		log.Fatalf("Failed to seed books: %v", err)
	}

	log.Println("✅ Books seeded successfully")
}
