package http

import (
	"io"
	"strconv"
	"book-service/domain"
	"book-service/middleware"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type BookHandler struct {
	bookUsecase domain.BookUsecase
}

func NewBookHandler(app *fiber.App, uc domain.BookUsecase) {
	handler := &BookHandler{bookUsecase: uc}

	api := app.Group("/api/v1")
	books := api.Group("/books")

	// Public routes
	books.Get("/", handler.GetAllBooks)

	// Protected routes (require auth)
	// Must be defined before /:id to avoid treating "favorites" as an ID
	books.Get("/favorites", middleware.RequireAuth, handler.GetUserFavorites)
	
	books.Get("/:id", handler.GetBookByID)
	books.Post("/:id/favorite", middleware.RequireAuth, handler.ToggleFavorite)

	// Admin routes
	adminBooks := books.Group("/", middleware.RequireAuth, middleware.RequireAdmin)
	adminBooks.Post("/", handler.CreateBook)
	adminBooks.Put("/:id", handler.UpdateBook)
	adminBooks.Delete("/:id", handler.DeleteBook)
	adminBooks.Post("/:id/cover", handler.UploadCover)
}

func (h *BookHandler) GetAllBooks(c *fiber.Ctx) error {
	title := c.Query("title")
	category := c.Query("category")
	language := c.Query("language")
	
	minRatingStr := c.Query("min_rating")
	var minRating float64
	if minRatingStr != "" {
		if val, err := strconv.ParseFloat(minRatingStr, 64); err == nil {
			minRating = val
		}
	}

	filter := domain.BookFilter{
		Title:     title,
		Category:  category,
		MinRating: minRating,
		Language:  language,
	}

	books, err := h.bookUsecase.GetAllBooks(filter)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch books",
		})
	}

	return c.Status(fiber.StatusOK).JSON(books)
}

func (h *BookHandler) GetBookByID(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid UUID format",
		})
	}

	book, err := h.bookUsecase.GetBookByID(id)
	if err != nil {
		if err.Error() == "book not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "Book not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Internal server error",
		})
	}

	return c.Status(fiber.StatusOK).JSON(book)
}

func (h *BookHandler) ToggleFavorite(c *fiber.Ctx) error {
	userID, ok := c.Locals("user_id").(uint)
	if !ok || userID == 0 {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	idParam := c.Params("id")
	bookID, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid UUID format",
		})
	}

	isFavorited, err := h.bookUsecase.ToggleFavorite(userID, bookID)
	if err != nil {
		if err.Error() == "book not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "Book not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Internal server error",
		})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"favorited": isFavorited,
	})
}

func (h *BookHandler) GetUserFavorites(c *fiber.Ctx) error {
	userID, ok := c.Locals("user_id").(uint)
	if !ok || userID == 0 {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	books, err := h.bookUsecase.GetUserFavorites(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch favorites",
		})
	}

	return c.Status(fiber.StatusOK).JSON(books)
}

func (h *BookHandler) CreateBook(c *fiber.Ctx) error {
	var book domain.Book
	if err := c.BodyParser(&book); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body", "details": err.Error()})
	}

	if err := h.bookUsecase.CreateBook(&book); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create book"})
	}

	return c.Status(fiber.StatusCreated).JSON(book)
}

func (h *BookHandler) UpdateBook(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid UUID format"})
	}

	var book domain.Book
	if err := c.BodyParser(&book); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	if err := h.bookUsecase.UpdateBook(id, &book); err != nil {
		if err.Error() == "book not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Book not found"})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to update book"})
	}

	// Fetch updated book to return
	updatedBook, _ := h.bookUsecase.GetBookByID(id)
	return c.Status(fiber.StatusOK).JSON(updatedBook)
}

func (h *BookHandler) DeleteBook(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid UUID format"})
	}

	if err := h.bookUsecase.DeleteBook(id); err != nil {
		if err.Error() == "book not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Book not found"})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to delete book"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{"message": "Book deleted successfully"})
}

func (h *BookHandler) UploadCover(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid UUID format"})
	}

	fileHeader, err := c.FormFile("cover_image")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "cover_image is required"})
	}

	file, err := fileHeader.Open()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to open file"})
	}
	defer file.Close()

	fileData, err := io.ReadAll(file)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to read file"})
	}

	contentType := fileHeader.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}

	coverURL, err := h.bookUsecase.UploadCoverImage(id, fileData, fileHeader.Filename, contentType)
	if err != nil {
		if err.Error() == "book not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "Book not found"})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message":   "Cover image uploaded successfully",
		"cover_url": coverURL,
	})
}
