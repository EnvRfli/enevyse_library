package config

import (
	"fmt"
	"log"
	"os"

	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func ConnectDatabase() {
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		log.Fatal("DATABASE_URL environment variable is not set")
	}

	db, err := gorm.Open(postgres.New(postgres.Config{
		DSN:                  dsn,
		PreferSimpleProtocol: true, // Required for Supabase PgBouncer (Transaction Pooler)
	}), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Konfigurasi Connection Pool untuk mencegah koneksi "mati/idle" diputus oleh PgBouncer
	sqlDB, err := db.DB()
	if err == nil {
		sqlDB.SetMaxIdleConns(2)
		sqlDB.SetMaxOpenConns(20)
		sqlDB.SetConnMaxLifetime(time.Minute * 5)
	}

	DB = db
	fmt.Println("✅ Database connected successfully")
}
