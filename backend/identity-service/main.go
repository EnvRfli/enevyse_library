package main

import (
	"identity-service/config"
	"identity-service/domain"
	deliveryHTTP "identity-service/delivery/http"
	"identity-service/repository"
	"identity-service/usecase"
	"log"
	"os"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/joho/godotenv"
)

func main() {
	// Load environment variables dari file .env
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  No .env file found, using system environment variables")
	}

	// Inisialisasi koneksi database
	config.ConnectDatabase()

	// Auto-migrate schema user ke database
	if err := config.DB.AutoMigrate(&domain.User{}); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}
	log.Println("✅ Database migration completed")

	// Inisialisasi layer-layer aplikasi (Dependency Injection)
	userRepo := repository.NewUserRepository(config.DB)
	userUC := usecase.NewUserUsecase(userRepo)

	// Inisialisasi Fiber app
	app := fiber.New(fiber.Config{
		AppName: "Identity Service v1.0",
	})

	// Middleware global
	app.Use(logger.New())
	app.Use(recover.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*", // Untuk produksi, ganti "*" dengan URL Frontend (contoh: "http://localhost:3000")
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
		AllowMethods: "GET, POST, HEAD, PUT, DELETE, PATCH, OPTIONS",
	}))

	// Health check endpoint
	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":  "ok",
			"service": "identity-service",
		})
	})

	// Daftarkan handler HTTP
	deliveryHTTP.NewUserHandler(app, userUC, userRepo)

	// Jalankan server
	port := os.Getenv("APP_PORT")
	if port == "" {
		port = "3001"
	}

	log.Printf("🚀 Identity Service running on port %s", port)
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
