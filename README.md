# 📚 Vyse Library Management App

Sebuah aplikasi manajemen perpustakaan modern berbasis **Microservices** menggunakan **Golang (Fiber)** untuk Backend, **Flutter** untuk Mobile App, **PostgreSQL** untuk Database, dan **RabbitMQ** untuk *Message Broker*.

Aplikasi ini mendemonstrasikan implementasi *Clean Architecture*, *SOLID Principles*, JWT Authentication, dan *Asynchronous Event-Driven Communication*.

## 🚀 Cara Menjalankan Secara Lokal (Local Development)

Jika Anda ingin menjalankan atau menguji aplikasi ini secara lokal di mesin Anda, silakan ikuti petunjuk berikut.

### 📋 Persyaratan Sistem (Prerequisites)
Pastikan Anda sudah menginstal alat-halat berikut:
- **Docker & Docker Compose** (Untuk PostgreSQL dan RabbitMQ)
- **Go** (Minimal versi v1.21)
- **Flutter SDK** (Minimal versi 3.27.x)
- **Dart** (Minimal versi 3.6.x)

---

### 1️⃣ Menjalankan Infrastruktur (Docker)
Aplikasi ini membutuhkan Database PostgreSQL dan RabbitMQ Message Broker. Konfigurasinya sudah disediakan di file `docker-compose.yml`. Buka terminal di folder root (*library-technical-test*) dan jalankan:

```bash
docker-compose up -d
