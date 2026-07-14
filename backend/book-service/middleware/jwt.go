package middleware

import (
	"os"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

// RequireAuth adalah middleware Fiber yang memvalidasi JWT dari header Authorization.
// Jika token valid, meng-inject "user_id", "email", dan "role" ke dalam c.Locals.
// Harus dijalankan SEBELUM RequireAdmin.
func RequireAuth(c *fiber.Ctx) error {
	// 1. Ambil header Authorization
	authHeader := c.Get("Authorization")
	if authHeader == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Missing Authorization header",
		})
	}

	// 2. Pastikan format "Bearer <token>"
	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid Authorization header format. Expected: Bearer <token>",
		})
	}

	tokenString := parts[1]
	if tokenString == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Token is empty",
		})
	}

	// 3. Parse dan verifikasi token menggunakan JWT_SECRET
	secret := os.Getenv("JWT_SECRET")
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Pastikan algoritma signing adalah HMAC (HS256)
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fiber.ErrUnauthorized
		}
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid or expired token",
		})
	}

	// 4. Ekstrak claims dan inject ke Fiber context
	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid token claims",
		})
	}

	// JWT menyimpan angka sebagai float64
	userID, ok := claims["user_id"].(float64)
	if !ok {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid token payload: user_id not found",
		})
	}

	email, _ := claims["email"].(string)
	role, _ := claims["role"].(string) // ← RBAC: inject role ke context

	c.Locals("user_id", uint(userID))
	c.Locals("email", email)
	c.Locals("role", role)

	return c.Next()
}

// RequireAdmin adalah middleware RBAC yang memastikan pengguna memiliki role "admin".
// WAJIB digunakan SETELAH RequireAuth karena bergantung pada c.Locals("role")
// yang di-set oleh RequireAuth.
//
// Contoh penggunaan:
//
//	api.Get("/admin-only", middleware.RequireAuth, middleware.RequireAdmin, handler)
func RequireAdmin(c *fiber.Ctx) error {
	role, ok := c.Locals("role").(string)
	if !ok || role == "" {
		// role tidak ada di context → RequireAuth belum dijalankan
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Unauthorized: no role found in token",
		})
	}

	if role != "admin" {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error":    "Forbidden: admin access required",
			"your_role": role,
		})
	}

	return c.Next()
}

// JWTProtected adalah alias backward-compatible yang membungkus RequireAuth.
// Dipertahankan agar route yang sudah ada (e.g. /me) tidak perlu diubah.
func JWTProtected() fiber.Handler {
	return RequireAuth
}
