# Rangkuman Belajar SQL dengan SQLite

## Persiapan

### 1. Tools yang Digunakan
- **VSCode** - Text editor dengan integrated terminal
- **SQLite3** - Database engine (sudah terinstall: v3.53.2)

### 2. Database yang Dibuat
- File: `latihan.db`
- Lokasi: `D:/#MY DATA/AI & DATA/SQL-DUMMY/latihan.db`

---

## Yang Sudah Dipelajari

### Level 1: Dasar - Terbentuk
- [x] Buat database baru
- [x] Buat tabel
- [x] Insert data
- [x] Select data

### Command Dasar SQLite Shell

| Command | Fungsi |
|---------|--------|
| `.tables` | Lihat semua tabel |
| `.schema nama_tabel` | Lihat struktur tabel |
| `.headers on` | Tampilkan nama kolom |
| `.mode column` | Format rapikan |
| `.read file.sql` | Jalankan file SQL |
| `.exit` | Keluar |

### Contoh Syntax Dasar

```sql
-- Buat tabel
CREATE TABLE siswa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    umur INTEGER,
    kota TEXT
);

-- Tambah data
INSERT INTO siswa (nama, umur, kota) VALUES ('Andi', 20, 'Jakarta');

-- Ambil data
SELECT * FROM siswa;
```

---

## Topik yang Belum Dipelajari

| Topik | File Latihan |
|-------|-------------|
| WHERE & FILTER | 02_where_filter.sql |
| ORDER BY | 03_order_by.sql |
| LIMIT & OFFSET | 04_limit_offset.sql |
| UPDATE & DELETE | 06_update.sql, 07_delete.sql |
| CREATE TABLE | 08_create_table.sql |
| JOIN | 09_join.sql |
| GROUP BY | 10_group_by.sql |
| SUBQUERY | 11_subquery.sql |
| CASE | 12_case.sql |

---

## Catatan Penting

1. **SQLite otomatis menyimpan** setiap perubahan (INSERT, UPDATE, DELETE)
2. **Tidak perlu command save manual** untuk menyimpan data
3. **Backup database** dengan command:
   ```sql
   sqlite3 latihan.db ".backup latihan_backup.db"
   ```

---

## File Latihan

Tersedia 12 file latihan di folder `latihan/`:
```
latihan/
├── 01_select_dasar.sql
├── 02_where_filter.sql
├── 03_order_by.sql
├── 04_limit_offset.sql
├── 05_insert.sql
├── 06_update.sql
├── 07_delete.sql
├── 08_create_table.sql
├── 09_join.sql
├── 10_group_by.sql
├── 11_subquery.sql
└── 12_case.sql
```

**Catatan:** File-file tersebut perlu diedit untuk kompatibilitas SQLite (misal: AUTO_INCREMENT → AUTOINCREMENT)

---

## Roadmap Belajar Berikutnya

1. **WHERE & FILTER** - Memfilter data dengan kondisi
2. **ORDER BY** - Mengurutkan hasil query
3. **JOIN** - Menghubungkan 2+ tabel
4. **GROUP BY** - Mengelompokkan dan agregasi data
5. **UPDATE & DELETE** - Memodifikasi dan menghapus data

---

Tanggal: 15 Juni 2026
