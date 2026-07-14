package http

import (
	"transaction-service/domain"
	"transaction-service/middleware"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type TransactionHandler struct {
	txUsecase domain.TransactionUsecase
}

func NewTransactionHandler(app *fiber.App, uc domain.TransactionUsecase) {
	handler := &TransactionHandler{txUsecase: uc}

	api := app.Group("/api/v1")
	
	// Protected routes
	txs := api.Group("/transactions", middleware.RequireAuth)
	txs.Post("/borrow", handler.BorrowBook)
	txs.Get("/me", handler.GetMyTransactions)
	txs.Get("/:id", handler.GetTransactionByID)
	
	// User extend route
	txs.Post("/:id/extend", handler.ExtendBorrow)

	// Admin-only lifecycle routes
	txs.Patch("/:id/pickup", middleware.RequireAdmin, handler.PickupBook)
	txs.Post("/:id/return", middleware.RequireAdmin, handler.ReturnBook)
}

func (h *TransactionHandler) BorrowBook(c *fiber.Ctx) error {
	// user_id is injected by RequireAuth middleware
	userIDRaw, ok := c.Locals("user_id").(uint)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}
	
	// JWT claims uint vs uuid conversion might be tricky if user_id was uint in identity service
	// Wait, in identity-service, user_id is uint! But here, Transaction struct expects uuid.UUID for UserID.
	// We have a mismatch! Let's temporarily cast it, but wait, uuid is string.
	// Oh! I see a potential bug. In identity-service User.ID is `uint`. In transaction-service UserID is `uuid.UUID`.
	// I must use the correct type. Since identity service uses uint, the transaction service must store UserID as uint.
	// I will fix this in domain/transaction.go right after this.
	// For now, assume UserID is uint in this service as well.
	
	var req domain.BorrowRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if req.BookID == uuid.Nil || req.PickupLocation == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "book_id and pickup_location are required",
		})
	}

	// Will be fixed in a moment to handle uint UserID
	// tx, err := h.txUsecase.BorrowBook(uint(userIDRaw), &req)
	
	// Wait, let's just write the handler assuming we change domain/transaction.go UserID to uint.
	tx, err := h.txUsecase.BorrowBook(userIDRaw, &req)
	if err != nil {
		if err.Error() == "You can only borrow up to 3 books at a time." {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "Borrow request is pending librarian approval.",
		"transaction": tx,
	})
}

func (h *TransactionHandler) GetMyTransactions(c *fiber.Ctx) error {
	userIDRaw, ok := c.Locals("user_id").(uint)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	txs, err := h.txUsecase.GetMyTransactions(userIDRaw)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch transactions",
		})
	}

	return c.Status(fiber.StatusOK).JSON(txs)
}

func (h *TransactionHandler) GetTransactionByID(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid UUID format",
		})
	}

	// Optional: Check if the transaction belongs to the logged-in user
	// userIDRaw := c.Locals("user_id").(uint)

	tx, err := h.txUsecase.GetTransactionByID(id)
	if err != nil {
		if err.Error() == "transaction not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "Transaction not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Internal server error",
		})
	}

	return c.Status(fiber.StatusOK).JSON(tx)
}

func (h *TransactionHandler) PickupBook(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid UUID format",
		})
	}

	tx, err := h.txUsecase.PickupBook(id)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(tx)
}

func (h *TransactionHandler) ExtendBorrow(c *fiber.Ctx) error {
	userIDRaw, ok := c.Locals("user_id").(uint)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid UUID format",
		})
	}

	tx, err := h.txUsecase.ExtendBorrow(userIDRaw, id)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(tx)
}

func (h *TransactionHandler) ReturnBook(c *fiber.Ctx) error {
	idParam := c.Params("id")
	id, err := uuid.Parse(idParam)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid UUID format",
		})
	}

	tx, err := h.txUsecase.ReturnBook(id)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(tx)
}
