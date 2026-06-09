# Catatan Belajar: Membaca Info SFP Module di MikroTik
**Penulis:** Fakih Arta Yuga | NOC Helpdesk Applewifi
**Tanggal:** Juni 2026

---

## 1. Apa itu SFP?

SFP singkatan dari **Small Form-factor Pluggable**. Ini adalah modul transceiver kecil yang dipasang di port SFP pada router atau switch MikroTik. Fungsinya mengubah sinyal listrik menjadi sinyal cahaya (fiber optik) atau sebaliknya.

Di Applewifi, SFP dipakai untuk menghubungkan antar node menggunakan kabel fiber optik. Contohnya port `sfp-sfpplus2 - METESEH` artinya port SFP kedua yang terhubung ke node Meteseh.

---

## 2. Tanda Link Sudah UP

Ini yang paling penting untuk NOC. Dari gambar, tanda link sudah UP bisa dilihat dari:

### Di Interface List:
| Indikator | Artinya |
|---|---|
| Status **R** di kolom kiri | Running — interface aktif dan ada traffic |
| Status **RS** | Running + Slave — aktif dan tergabung ke bridge/bonding |
| Status **S** | Slave saja — tergabung tapi tidak running |
| Tidak ada huruf | Interface down / tidak ada koneksi |

### Di bagian bawah jendela SFP:
| Teks | Artinya |
|---|---|
| **enabled** | Interface diaktifkan secara manual |
| **running** | Fisik terhubung dan aktif |
| **link ok** | ✅ Koneksi fiber berhasil, link sudah UP |

**Dari contoh di gambar:** status menunjukkan `enabled | running | slave | link ok` — artinya link ke Meteseh dalam kondisi normal dan UP.

---

## 3. Penjelasan Setiap Field di Tab SFP

### Informasi Fisik Modul

| Field | Nilai di Gambar | Penjelasan |
|---|---|---|
| SFP Shutdown Temperature | 95 C | Suhu maksimal sebelum modul otomatis mati untuk mencegah kerusakan |
| SM Link Length | 20.000 km | Jarak maksimal kabel fiber yang bisa dijangkau modul ini (Single Mode, 20 km) |
| Vendor Name | HSGQ | Nama produsen modul SFP |
| Vendor Part Number | SFP10G20LR27A | Kode produk modul |
| Vendor Revision | V02 | Versi hardware modul |
| Vendor Serial | 2725042902535 | Nomor seri unik modul |
| Manufacturing Date | 25-05-07 | Tanggal produksi (7 Mei 2025) |

### Informasi Sinyal (Paling Penting untuk NOC)

| Field | Nilai di Gambar | Normal | Kritis |
|---|---|---|---|
| Wavelength | 1270.00 nm | - | - |
| Temperature | 47 C | 0-70 C | > 80 C mulai waspada |
| Supply Voltage | 3.297 V | 3.1 - 3.5 V | Di luar range = masalah |
| Tx Bias Current | 41 mA | 5-80 mA | > 100 mA = waspada |
| **Tx Power** | **-1.749 dBm** | -3 s/d +3 dBm | < -7 dBm = lemah |
| **Rx Power** | **-11.432 dBm** | -3 s/d -20 dBm | < -27 dBm = kritis |

---

## 4. Fokus Utama: Tx Power dan Rx Power

Ini dua nilai yang paling sering dilihat NOC untuk diagnosis gangguan.

### Tx Power (Transmit Power)
Kekuatan sinyal yang **dikirim** oleh modul SFP ini ke arah node tujuan.

Nilai **-1.749 dBm** pada contoh ini tergolong **bagus** — sinyal yang dikirim ke Meteseh kuat.

### Rx Power (Receive Power)
Kekuatan sinyal yang **diterima** oleh modul SFP ini dari node tujuan.

Nilai **-11.432 dBm** pada contoh ini tergolong **normal** — sinyal yang diterima dari Meteseh cukup baik.

### Skala dBm untuk Rx Power

```
0 dBm          Sangat kuat (jarang terjadi di FO jarak jauh)
|
-8 dBm         Batas atas normal
|
-11 dBm        ← POSISI METESEH SEKARANG (Normal ✅)
|
-20 dBm        Batas bawah normal, mulai perlu diperhatikan
|
-27 dBm        Zona kritis, koneksi mulai tidak stabil ⚠️
|
-30 dBm ke bawah    Link bisa putus sewaktu-waktu ❌
```

### Penyebab Rx Power rendah (redaman tinggi):
- Kabel fiber tertekuk tajam
- Konektor kotor atau longgar
- Kabel fiber putus sebagian
- Jarak kabel terlalu panjang melebihi kapasitas modul
- Splice (sambungan) kabel yang buruk

---

## 5. Cara Diagnosis Menggunakan Info SFP

### Skenario 1: Pelanggan di area Meteseh komplain lemot
1. Buka MikroTik → Interface List → klik `sfp-sfpplus2 - METESEH`
2. Klik tab SFP
3. Cek **Rx Power** — kalau di atas -20 dBm, sinyal masih normal
4. Cek **status bawah** — pastikan ada tulisan `link ok`
5. Kalau Rx Power sudah di bawah -27 dBm → redaman tinggi → eskalasi ke teknisi lapangan

### Skenario 2: Link ke Meteseh tiba-tiba down
1. Cek Interface List — status berubah dari R menjadi tidak ada huruf
2. Buka tab SFP — cek apakah Rx Power drop drastis atau kosong
3. Kalau Rx Power kosong/nol → kemungkinan kabel putus atau konektor lepas
4. Kalau Rx Power ada tapi sangat rendah (< -30 dBm) → kabel bermasalah
5. Eskalasi ke teknisi untuk pengecekan fisik

---

## 6. Perbedaan SM dan MM pada SFP

| | Single Mode (SM) | Multi Mode (MM) |
|---|---|---|
| Warna konektor | Biru/Kuning | Beige/Abu |
| Jarak | Hingga 80 km | Maksimal 2 km |
| Kabel | Inti kecil (9 mikron) | Inti besar (50/62.5 mikron) |
| Penggunaan | Antar gedung/node jauh | Dalam gedung |
| Harga | Lebih mahal | Lebih murah |

Modul di gambar adalah **SM 20 km** — cocok untuk jarak antar node Applewifi yang bisa sampai belasan kilometer.

---

## 7. Ringkasan Checklist Link UP

Kalau semua poin ini terpenuhi, link bisa dipastikan UP dan normal:

- [ ] Status interface menunjukkan **R** atau **RS** di Interface List
- [ ] Bagian bawah jendela SFP menunjukkan **link ok**
- [ ] **Rx Power** di atas **-20 dBm** (idealnya -3 sampai -15 dBm)
- [ ] **Tx Power** di atas **-7 dBm**
- [ ] **Temperature** di bawah **70 C**
- [ ] **Supply Voltage** antara **3.1 - 3.5 V**
- [ ] Ada traffic (Tx/Rx) di kolom Interface List

---

*Catatan ini dibuat berdasarkan pembelajaran langsung di lapangan bersama senior NOC Applewifi. Simpan di GitHub portfolio: yugaaajago/My-Learn*
