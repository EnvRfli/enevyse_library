# Build stage
FROM golang:alpine AS builder

# Install git and other necessary tools
RUN apk update && apk add --no-cache git tzdata

WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main .

# Run stage
FROM alpine:latest

# Add timezone data and ca-certificates (needed for HTTPS calls to Supabase)
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy the pre-built binary file from the previous stage
COPY --from=builder /app/main .

# Expose port
EXPOSE 8002

# Run the executable
CMD ["./main"]
