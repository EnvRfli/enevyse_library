package domain

import (
	"time"

	"github.com/lib/pq"
)

// Konstanta Role untuk menghindari magic string di seluruh codebase.
const (
	RoleUser  = "user"
	RoleAdmin = "admin"
)

// User adalah entitas utama yang merepresentasikan pengguna dalam sistem.
type User struct {
	ID                uint      `gorm:"primaryKey;autoIncrement" json:"id"`
	MemberID          string    `gorm:"uniqueIndex" json:"member_id"` // Generated uniquely
	Name              string    `gorm:"not null" json:"name"`
	Email             string    `gorm:"uniqueIndex;not null" json:"email"`
	Password          string    `gorm:"not null" json:"-"`
	Role              string    `gorm:"not null;default:user" json:"role"`
	Phone             string    `json:"phone"`
	Address           string    `json:"address"`
	ProfilePictureURL   string         `json:"profile_picture_url"`
	PreferredCategories pq.StringArray `gorm:"type:text[]" json:"preferred_categories"`
	MembershipStatus    string         `gorm:"not null;default:ACTIVE" json:"membership_status"` // ACTIVE, SUSPENDED
	CreatedAt           time.Time      `json:"created_at"`
	UpdatedAt           time.Time      `json:"updated_at"`
}

// RegisterRequest adalah struct untuk payload registrasi pengguna.
type RegisterRequest struct {
	Name     string `json:"name" validate:"required"`
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required,min=6"`
}

// LoginRequest adalah struct untuk payload login pengguna.
type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

// AuthResponse adalah struct untuk respons setelah login/register berhasil.
type AuthResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type UpdateProfileRequest struct {
	Phone               string   `json:"phone"`
	Address             string   `json:"address"`
	ProfilePictureURL   string   `json:"profile_picture_url"`
	PreferredCategories []string `json:"preferred_categories"`
}

// UpdateMembershipRequest is the payload for an admin to update a user's status
type UpdateMembershipRequest struct {
	Status string `json:"status" validate:"required,oneof=ACTIVE SUSPENDED"`
}

// UserRepository mendefinisikan kontrak untuk operasi database user.
type UserRepository interface {
	Create(user *User) error
	FindByEmail(email string) (*User, error)
	FindByID(id uint) (*User, error)
	Update(user *User) error
}

// UserUsecase mendefinisikan kontrak untuk logika bisnis user.
type UserUsecase interface {
	Register(req *RegisterRequest) (*AuthResponse, error)
	Login(req *LoginRequest) (*AuthResponse, error)
	UpdateProfile(userID uint, req *UpdateProfileRequest) (*User, error)
	UpdateMembershipStatus(userID uint, status string) (*User, error)
}
