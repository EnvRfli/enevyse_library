package config

import (
	"identity-service/domain"
	"log"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func SeedAdmin(db *gorm.DB) {
	var count int64
	db.Model(&domain.User{}).Where("email = ?", "admin@library.com").Count(&count)

	if count > 0 {
		log.Println("👤 Admin account already exists, skipping seeder")
		return
	}

	log.Println("🌱 Seeding admin account...")

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)
	if err != nil {
		log.Printf("Failed to hash admin password: %v", err)
		return
	}

	admin := domain.User{
		MemberID:         "LIB-ADMIN-001",
		Name:             "Super Admin",
		Email:            "admin@library.com",
		Password:         string(hashedPassword),
		Role:             domain.RoleAdmin,
		MembershipStatus: "ACTIVE",
	}

	if err := db.Create(&admin).Error; err != nil {
		log.Printf("Failed to seed admin: %v", err)
	} else {
		log.Println("✅ Admin account seeded successfully (Email: admin@library.com | Password: admin123)")
	}
}
