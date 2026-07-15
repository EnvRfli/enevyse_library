package usecase

import (
	"errors"
	"identity-service/domain"
	"fmt"
	"math/rand"
	"os"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
)

// userUsecase adalah implementasi dari domain.UserUsecase.
type userUsecase struct {
	userRepo domain.UserRepository
}

// NewUserUsecase membuat instance baru dari userUsecase.
func NewUserUsecase(repo domain.UserRepository) domain.UserUsecase {
	return &userUsecase{userRepo: repo}
}

// Register menangani logika registrasi pengguna baru.
func (u *userUsecase) Register(req *domain.RegisterRequest) (*domain.AuthResponse, error) {
	// Cek apakah email sudah terdaftar
	existing, err := u.userRepo.FindByEmail(req.Email)
	if err != nil {
		return nil, err
	}
	if existing != nil {
		return nil, errors.New("email already registered")
	}

	// Hash password sebelum disimpan
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, errors.New("failed to hash password")
	}

	// Generate MemberID: LIB-YYYY-RandomNumber
	year := time.Now().Year()
	randNum := rand.Intn(9000) + 1000 // 1000-9999
	memberID := fmt.Sprintf("LIB-%d-%d", year, randNum)

	user := &domain.User{
		MemberID:         memberID,
		Name:             req.Name,
		Email:            req.Email,
		Password:         string(hashedPassword),
		Role:             domain.RoleUser, // default role untuk semua user baru
		MembershipStatus: "ACTIVE",
	}

	if err := u.userRepo.Create(user); err != nil {
		return nil, errors.New("failed to create user")
	}

	// Generate JWT token
	token, err := generateJWT(user)
	if err != nil {
		return nil, err
	}

	return &domain.AuthResponse{Token: token, User: *user}, nil
}

// Login menangani logika autentikasi pengguna.
func (u *userUsecase) Login(req *domain.LoginRequest) (*domain.AuthResponse, error) {
	user, err := u.userRepo.FindByEmail(req.Email)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("invalid email or password")
	}

	// Verifikasi password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid email or password")
	}

	// Generate JWT token
	token, err := generateJWT(user)
	if err != nil {
		return nil, err
	}

	return &domain.AuthResponse{Token: token, User: *user}, nil
}

// UpdateProfile updates the profile information for a user
func (u *userUsecase) UpdateProfile(userID uint, req *domain.UpdateProfileRequest) (*domain.User, error) {
	user, err := u.userRepo.FindByID(userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}

	if req.Phone != "" {
		user.Phone = req.Phone
	}
	if req.Address != "" {
		user.Address = req.Address
	}
	if req.ProfilePictureURL != "" {
		user.ProfilePictureURL = req.ProfilePictureURL
	}
	if len(req.PreferredCategories) > 0 {
		user.PreferredCategories = req.PreferredCategories
	}

	user.UpdatedAt = time.Now()

	if err := u.userRepo.Update(user); err != nil {
		return nil, errors.New("failed to update profile")
	}

	return user, nil
}

// UpdateMembershipStatus updates the membership status for a user
func (u *userUsecase) UpdateMembershipStatus(userID uint, status string) (*domain.User, error) {
	user, err := u.userRepo.FindByID(userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}

	user.MembershipStatus = status
	user.UpdatedAt = time.Now()

	if err := u.userRepo.Update(user); err != nil {
		return nil, errors.New("failed to update membership status")
	}

	return user, nil
}

// generateJWT membuat JWT token untuk pengguna yang terautentikasi.
// Claims yang disertakan: user_id, email, role, exp, iat.
func generateJWT(user *domain.User) (string, error) {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return "", errors.New("JWT_SECRET is not configured")
	}

	claims := jwt.MapClaims{
		"user_id": user.ID,
		"email":   user.Email,
		"role":    user.Role, // ← RBAC: disertakan agar middleware bisa cek tanpa query DB
		"exp":     time.Now().Add(24 * time.Hour).Unix(),
		"iat":     time.Now().Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret))
}
