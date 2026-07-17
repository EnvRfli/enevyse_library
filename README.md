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
Aplikasi ini membutuhkan Database PostgreSQL dan RabbitMQ Message Broker. Konfigurasinya sudah disediakan di file `docker-compose.yml`. Buka terminal di folder root (`library-technical-test`) dan jalankan:

```bash
docker-compose up -d
```
> **Catatan:** Perintah ini akan menjalankan PostgreSQL di port `15432` dan RabbitMQ di port `5672` (Dashboard RabbitMQ dapat diakses di `http://localhost:15672` dengan kredensial `guest` / `guest`).

---

### 2️⃣ Konfigurasi Backend Environment (.env)
Kredensial dan konfigurasi rahasia (*Environment Variables*) untuk **PostgreSQL, RabbitMQ, JWT Secret, dan Supabase Bucket** tidak disertakan di dalam repositori publik ini.

File `.env` untuk ketiga service (`identity-service`, `book-service`, `transaction-service`) telah saya sertakan di dalam folder **Google Drive**. Link folder tersebut sudah saya lampirkan di dalam **Email Submission**.

Silakan unduh ketiga file `.env` tersebut dan letakkan di dalam folder masing-masing:
- `backend/identity-service/.env`
- `backend/book-service/.env`
- `backend/transaction-service/.env`

Setelah itu, buka 3 tab terminal baru dan jalankan masing-masing service dengan perintah:
```bash
cd backend/identity-service && go run main.go
cd backend/book-service && go run main.go
cd backend/transaction-service && go run main.go
```

---

### 3️⃣ Akun Admin & Data Dummy (Seeder)
Sistem memiliki seeder bawaan (*auto-migrate* & *auto-seed*) yang berjalan secara otomatis saat backend pertama kali dinyalakan.

- **Data Buku Dummy:** Otomatis tersedia di database.
- **Akun Admin Default:**
  - **Email:** `admin@library.com`
  - **Password:** `admin123`

*(Gunakan kredensial admin di atas pada aplikasi Flutter untuk masuk dan mengakses fitur Admin Panel).*

---

### 4️⃣ Konfigurasi Mobile App (Flutter)
Secara *default*, kode sumber pada aplikasi ini mengarah ke URL *Production* (Render.com). Untuk menyambungkannya ke server backend lokal yang baru saja Anda jalankan, ikuti langkah berikut:

1. Buka file `frontend/enevyse_library/lib/core/network/api_client.dart`.
2. Hapus komentar (*uncomment*) pada bagian konfigurasi Localhost, dan beri komentar (*comment*) pada konfigurasi Production.

```dart
class ApiClient {
  // === CONFIG PRODUCTION (Abaikan jika main di lokal) ===
  // static const String identityBaseUrl = 'https://vyse-identity-service.onrender.com';
  // static const String bookBaseUrl = 'https://vyse-book-service.onrender.com';
  // static const String transactionBaseUrl = 'https://vyse-transaction-service.onrender.com';

  // === CONFIG LOCALHOST (Khusus Android Emulator) ===
  static const String identityBaseUrl = 'http://10.0.2.2:3001';
  static const String bookBaseUrl = 'http://10.0.2.2:8002';
  static const String transactionBaseUrl = 'http://10.0.2.2:8003';

  // === CONFIG LOCALHOST (iOS Simulator / Web / Windows) ===
  // static const String identityBaseUrl = 'http://127.0.0.1:3001';
  // static const String bookBaseUrl = 'http://127.0.0.1:8002';
  // static const String transactionBaseUrl = 'http://127.0.0.1:8003';
  
  // ... sisa kode tidak diubah
}
```
*(Catatan Penting: Untuk **Android Emulator**, Anda wajib menggunakan IP `10.0.2.2` karena Emulator Android tidak mengenali `localhost/127.0.0.1` sebagai IP mesin utama komputer Anda).*

**Jalankan Aplikasi Mobile:**
Buka terminal dan arahkan ke direktori Flutter:
```bash
cd frontend/enevyse_library
flutter clean
flutter pub get
flutter run
```

---
🎉 **Selamat!** Aplikasi Library Management sekarang sudah berjalan penuh secara lokal.
