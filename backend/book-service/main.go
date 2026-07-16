package main

import (
	"log"
	"os"
	"book-service/config"
	deliveryHTTP "book-service/delivery/http"
	"book-service/domain"
	"book-service/internal/messaging"
	"book-service/repository"
	"book-service/usecase"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("⚠️  No .env file found, using system environment variables")
	}

	config.ConnectDatabase()

	if err := config.DB.AutoMigrate(&domain.Book{}, &domain.FavoriteBook{}); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}
	log.Println("✅ Database migration completed")

	// Run seeder
	config.SeedBooks(config.DB)

	bookRepo := repository.NewBookRepository(config.DB)
	bookUC := usecase.NewBookUsecase(bookRepo)

	// Start RabbitMQ Consumers in background
	go messaging.ConsumeBookingRequests(bookRepo)
	go messaging.ConsumeReturnEvents(bookRepo)

	app := fiber.New(fiber.Config{
		AppName: "Book Service v1.0",
	})

	app.Use(logger.New())
	app.Use(recover.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
		AllowMethods: "GET, POST, HEAD, PUT, DELETE, PATCH, OPTIONS",
	}))

	app.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status":  "ok",
			"service": "book-service",
		})
	})

	deliveryHTTP.NewBookHandler(app, bookUC)

	port := os.Getenv("PORT") // Default dari Render.com
	if port == "" {
		port = os.Getenv("APP_PORT")
	}
	if port == "" {
		port = "8002"
	}

	log.Printf("🚀 Book Service running on port %s", port)
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
