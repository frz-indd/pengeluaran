# 📱 Aplikasi Pengeluaran Bulanan - Flutter

Aplikasi Android untuk mencatat dan memantau pengeluaran bulanan dengan fitur dashboard, kategori, dan analisis.

## ✨ Fitur Utama

- 📊 **Dashboard** - Ringkasan pengeluaran bulan dengan grafik per kategori
- ➕ **Tambah Pengeluaran** - Form lengkap untuk mencatat pengeluaran baru
- 📋 **Riwayat Pengeluaran** - Daftar lengkap dengan filter kategori
- 🏷️ **8 Kategori** - Makanan, Transportasi, Hiburan, Kesehatan, Belanja, Tagihan, Pendidikan, Lainnya
- 🗓️ **Navigasi Bulan** - Lihat pengeluaran bulan sebelumnya/sesudahnya
- 💾 **Database Lokal** - Semua data tersimpan di perangkat (SQLite)
- 🌍 **Lokalisasi** - Antarmuka dalam Bahasa Indonesia
- 🎨 **Material Design 3** - UI modern dan responsif

## 📦 Struktur Project

```
lib/
├── main.dart                    # Entry point aplikasi
├── models/
│   ├── expense.dart            # Model untuk pengeluaran
│   └── category.dart           # Model dan daftar kategori
├── services/
│   └── database_service.dart    # Service untuk database SQLite
├── providers/
│   └── expense_provider.dart    # State management dengan Provider
└── screens/
    ├── home_screen.dart        # Dashboard & navigasi utama
    ├── add_expense_screen.dart  # Form tambah/edit pengeluaran
    └── expense_list_screen.dart # Daftar pengeluaran dengan filter
```

## 🚀 Cara Menjalankan

### Setup & Jalankan

```powershell
# 1. Navigasi ke project directory
cd "c:\xampp\htdocs\monthly outcome\monthly_outcome"

# 2. Download dependencies (sudah dilakukan)
C:\flutter_sdk\flutter\bin\flutter.bat pub get

# 3. Jalankan aplikasi
C:\flutter_sdk\flutter\bin\flutter.bat run

# 4. Untuk build APK (release)
C:\flutter_sdk\flutter\bin\flutter.bat build apk --release
```

## 🛠️ Dependencies

| Package | Fungsi |
|---------|--------|
| `provider` | State management |
| `sqflite` | Database lokal |
| `intl` | Lokalisasi & format currency |
| `fl_chart` | Visualisasi grafik |
| `path` | Path handling |
| `shared_preferences` | Menyimpan preference |
| `flutter_localizations` | Lokalisasi UI |

## 📚 Fitur Lengkap

### 1. Dashboard Screen
- Total pengeluaran bulan
- Breakdown per kategori dengan progress bar
- Daftar pengeluaran terbaru
- Navigasi bulan sebelumnya/sesudahnya

### 2. Add/Edit Expense
- Input judul dan jumlah pengeluaran
- Pilih kategori dengan chip selector
- Pilih tanggal dengan date picker
- Tambah catatan opsional
- Edit atau hapus pengeluaran yang ada

### 3. Expense List
- Daftar semua pengeluaran bulan
- Filter berdasarkan kategori
- Urutkan by date (terbaru dulu)
- Tap untuk edit, long-press untuk menu
- Tampil kategori dengan ikon & warna

## 💡 Cara Menggunakan

1. **Membuat Pengeluaran Baru**
   - Tap tombol ➕ (FAB)
   - Isi judul dan jumlah
   - Pilih kategori
   - Pilih tanggal (default hari ini)
   - Tambah catatan (opsional)
   - Tap "Simpan"

2. **Melihat Riwayat**
   - Tap tab "Riwayat" di bottom
   - Filter dengan kategori atau lihat semua
   - Tap item untuk edit
   - Long-press untuk menu hapus

3. **Analisis Pengeluaran**
   - Di dashboard, lihat:
     - Total pengeluaran bulan
     - Persentase per kategori
     - Progress bar visual

## 🎨 Kategori & Warna

| Kategori | Ikon | Warna |
|----------|------|-------|
| Makanan | 🍽️ | Merah (#FF6B6B) |
| Transportasi | 🚗 | Biru (#4ECDC4) |
| Hiburan | 🎬 | Kuning (#FFE66D) |
| Kesehatan | 🏥 | Hijau (#95E1D3) |
| Belanja | 🛍️ | Ungu (#C7CEEA) |
| Tagihan | 📄 | Ungu Gelap (#B4A7D6) |
| Pendidikan | 🎓 | Biru Muda (#74B9FF) |
| Lainnya | 📂 | Ungu (#A29BFE) |

## 🔒 Data & Privacy

- Semua data disimpan **lokal** di perangkat
- Menggunakan SQLite database
- **Tidak ada** koneksi internet atau cloud
- Data pribadi aman di tangan Anda

## 📝 Contoh Penggunaan

```dart
// Menambah pengeluaran
final expense = Expense(
  title: 'Makan Siang',
  amount: 50000,
  category: 'Makanan',
  date: DateTime.now(),
  description: 'Di warung samping kantor',
);
provider.addExpense(expense);

// Filter pengeluaran bulan
final expenses = await provider.getExpensesByMonth(2026, 4);

// Total pengeluaran
final total = await provider.getTotalExpensesByMonth(2026, 4);
```

## 🚀 Fitur yang Bisa Ditambahkan

- 📊 Grafik chart (pie, bar) dengan fl_chart
- 💾 Export ke Excel/CSV
- 🌙 Dark mode theme
- 🔔 Notifikasi budget alert
- 📈 Laporan trend bulanan
- 👥 Multi-user support
- ☁️ Cloud backup

---

**Happy Tracking! 🎉**
