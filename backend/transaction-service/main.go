package main

import (
	"log"
	"os"
	"transaction-service/config"
	deliveryHTTP "transaction-service/delivery/http"
	"transaction-service/domain"
	"transaction-service/internal/messaging"
	"transaction-service/repository"
	"transaction-service/usecase"

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

	if err := config.DB.AutoMigrate(&domain.Transaction{}); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}
	log.Println("✅ Database migration completed")

	txRepo := repository.NewTransactionRepository(config.DB)
	txUC := usecase.NewTransactionUsecase(txRepo)

	// Start RabbitMQ Consumer in background
	go messaging.ConsumeBookingReplies(txRepo)

	app := fiber.New(fiber.Config{
		AppName: "Transaction Service v1.0",
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
			"service": "transaction-service",
		})
	})

	deliveryHTTP.NewTransactionHandler(app, txUC)

	port := os.Getenv("PORT") // Default dari Render.com
	if port == "" {
		port = os.Getenv("APP_PORT")
	}
	if port == "" {
		port = "8003"
	}

	log.Printf("🚀 Transaction Service running on port %s", port)
	if err := app.Listen(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
