package http

import (
	"identity-service/domain"
	"identity-service/middleware"

	"github.com/gofiber/fiber/v2"
)

// UserHandler menangani HTTP request untuk endpoint user.
type UserHandler struct {
	userUsecase domain.UserUsecase
	userRepo    domain.UserRepository
}

// NewUserHandler membuat instance baru dari UserHandler dan mendaftarkan rute.
func NewUserHandler(app *fiber.App, uc domain.UserUsecase, repo domain.UserRepository) {
	handler := &UserHandler{userUsecase: uc, userRepo: repo}

	api := app.Group("/api/v1")

	// --- Public routes ---
	auth := api.Group("/auth")
	auth.Post("/register", handler.Register)
	auth.Post("/login", handler.Login)

	// --- Protected routes (membutuhkan JWT yang valid) ---
	api.Get("/me", middleware.RequireAuth, handler.GetMe)
	api.Put("/me", middleware.RequireAuth, handler.UpdateProfile)

	// --- Admin-only routes (membutuhkan JWT valid + role "admin") ---
	// Contoh chaining: RequireAuth → RequireAdmin → handler
	api.Get("/admin-only", middleware.RequireAuth, middleware.RequireAdmin, handler.AdminOnly)
	api.Patch("/users/:id/membership", middleware.RequireAuth, middleware.RequireAdmin, handler.UpdateMembership)
}

// Register godoc
// @Summary      Registrasi pengguna baru
// @Description  Membuat akun pengguna baru dengan nama, email, dan password
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body  body      domain.RegisterRequest  true  "Register Payload"
// @Success      201   {object}  domain.AuthResponse
// @Failure      400   {object}  map[string]string
// @Failure      409   {object}  map[string]string
// @Router       /auth/register [post]
func (h *UserHandler) Register(c *fiber.Ctx) error {
	var req domain.RegisterRequest

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Validasi field wajib
	if req.Name == "" || req.Email == "" || req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Name, email, and password are required",
		})
	}

	if len(req.Password) < 6 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Password must be at least 6 characters",
		})
	}

	response, err := h.userUsecase.Register(&req)
	if err != nil {
		if err.Error() == "email already registered" {
			return c.Status(fiber.StatusConflict).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Internal server error",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(response)
}

// Login godoc
// @Summary      Login pengguna
// @Description  Autentikasi pengguna dan mengembalikan JWT token
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body  body      domain.LoginRequest  true  "Login Payload"
// @Success      200   {object}  domain.AuthResponse
// @Failure      400   {object}  map[string]string
// @Failure      401   {object}  map[string]string
// @Router       /auth/login [post]
func (h *UserHandler) Login(c *fiber.Ctx) error {
	var req domain.LoginRequest

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if req.Email == "" || req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Email and password are required",
		})
	}

	response, err := h.userUsecase.Login(&req)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusOK).JSON(response)
}

// GetMe godoc
// @Summary      Profil pengguna saat ini
// @Description  Mengembalikan data pengguna yang sedang login berdasarkan JWT token
// @Tags         user
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  domain.User
// @Failure      401  {object}  map[string]string
// @Failure      404  {object}  map[string]string
// @Router       /me [get]
func (h *UserHandler) GetMe(c *fiber.Ctx) error {
	// Ambil user_id yang sudah di-inject oleh JWTProtected middleware
	userID, ok := c.Locals("user_id").(uint)
	if !ok || userID == 0 {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	user, err := h.userRepo.FindByID(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch user data",
		})
	}
	if user == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "User not found",
		})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"user_id":             user.ID,
		"member_id":           user.MemberID,
		"name":                user.Name,
		"email":               user.Email,
		"role":                user.Role,
		"phone":               user.Phone,
		"address":             user.Address,
		"profile_picture_url": user.ProfilePictureURL,
		"membership_status":   user.MembershipStatus,
	})
}

// UpdateProfile godoc
// @Summary      Update profil pengguna saat ini
// @Description  Memperbarui data profil pengguna yang sedang login
// @Tags         user
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body  body      domain.UpdateProfileRequest  true  "Update Profile Payload"
// @Success      200  {object}  domain.User
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Router       /me [put]
func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	userID, ok := c.Locals("user_id").(uint)
	if !ok || userID == 0 {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized",
		})
	}

	var req domain.UpdateProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	user, err := h.userUsecase.UpdateProfile(userID, &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Sembunyikan password di response
	user.Password = ""

	return c.Status(fiber.StatusOK).JSON(user)
}

// UpdateMembership godoc
// @Summary      Update status keanggotaan pengguna
// @Description  Admin dapat mengubah status keanggotaan pengguna (misalnya ACTIVE atau SUSPENDED)
// @Tags         admin
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id    path      int                          true  "User ID"
// @Param        body  body      domain.UpdateMembershipRequest true  "Update Membership Payload"
// @Success      200  {object}  domain.User
// @Failure      400  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Router       /users/{id}/membership [patch]
func (h *UserHandler) UpdateMembership(c *fiber.Ctx) error {
	idParam, err := c.ParamsInt("id")
	if err != nil || idParam <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid User ID",
		})
	}

	var req domain.UpdateMembershipRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if req.Status != "ACTIVE" && req.Status != "SUSPENDED" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Status must be ACTIVE or SUSPENDED",
		})
	}

	user, err := h.userUsecase.UpdateMembershipStatus(uint(idParam), req.Status)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Sembunyikan password di response
	user.Password = ""

	return c.Status(fiber.StatusOK).JSON(user)
}

// AdminOnly godoc
// @Summary      Endpoint khusus admin
// @Description  Hanya dapat diakses oleh pengguna dengan role "admin".
//
//	Contoh chaining middleware: RequireAuth → RequireAdmin → handler
//
// @Tags         admin
// @Produce      json
// @Security     BearerAuth
// @Success      200  {object}  map[string]string
// @Failure      401  {object}  map[string]string
// @Failure      403  {object}  map[string]string
// @Router       /admin-only [get]
func (h *UserHandler) AdminOnly(c *fiber.Ctx) error {
	// Pada titik ini RequireAuth & RequireAdmin sudah lolos,
	// sehingga c.Locals terjamin berisi data yang valid.
	userID := c.Locals("user_id").(uint)
	email := c.Locals("email").(string)
	role := c.Locals("role").(string)

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "Welcome to the admin panel!",
		"user_id": userID,
		"email":   email,
		"role":    role,
	})
}
