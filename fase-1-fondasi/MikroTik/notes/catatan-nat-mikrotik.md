# Catatan Belajar: NAT, SRC-NAT, DST-NAT & Port Forwarding
**Penulis:** Fakih Arta Yuga | NOC Helpdesk Applewifi
**Tanggal:** Juni 2026

---

## 1. Apa itu NAT?

NAT singkatan dari **Network Address Translation**. Fungsinya adalah menerjemahkan atau mengubah alamat IP pada paket data ketika melewati router.

Analoginya seperti kantor pos. Surat dari dalam rumah (IP private) dikirim keluar menggunakan alamat kantor (IP public), lalu balasan dari luar diterima kantor dan diteruskan ke dalam rumah yang sesuai.

NAT dibutuhkan karena:
- IP public jumlahnya terbatas dan mahal
- Banyak perangkat dalam jaringan lokal tidak bisa langsung punya IP public masing-masing
- Sebagai lapisan keamanan, karena IP lokal tidak terlihat langsung dari internet

---

## 2. SRC-NAT (Source NAT)

### Apa itu?
SRC-NAT mengubah **alamat pengirim (source)** pada paket data. Dipakai ketika perangkat dari jaringan lokal ingin mengakses internet.

### Cara kerjanya
Perangkat lokal (misal IP 25.8.20.5) mengirim request ke internet → MikroTik mengubah source address-nya menjadi IP public (misal 157.20.233.102) → server di internet menerima request dari 157.20.233.102 → balasan dikirim ke 157.20.233.102 → MikroTik terjemahkan kembali ke 25.8.20.5.

### Setting di MikroTik
- **Chain:** srcnat
- **Src. Address:** subnet pelanggan (misal 25.8.20.0/24)
- **Action:** masquerade atau src-nat
- **To Addresses:** IP public yang digunakan keluar (misal 157.20.233.102)

### Perbedaan Masquerade vs SRC-NAT
| | Masquerade | SRC-NAT |
|---|---|---|
| IP keluar | Mengikuti IP interface otomatis | IP ditentukan manual |
| Cocok untuk | Koneksi dinamis (DHCP) | IP public tetap/statis |
| Performa | Sedikit lebih lambat | Lebih efisien |

### Mengapa Applewifi pakai banyak IP untuk SRC-NAT?
Agar kalau satu IP public kena blacklist atau reputasinya buruk karena aktivitas salah satu pelanggan, hanya subnet tertentu yang terdampak. Subnet lain tetap bisa akses internet normal lewat IP public mereka masing-masing.

---

## 3. DST-NAT (Destination NAT) / Port Forwarding

### Apa itu?
DST-NAT mengubah **alamat tujuan (destination)** pada paket data. Dipakai ketika ada orang dari luar internet ingin mengakses perangkat atau server yang ada di dalam jaringan lokal.

### Apa itu Port Forwarding?
Port Forwarding adalah teknik menggunakan DST-NAT untuk meneruskan traffic dari IP public + port tertentu ke IP lokal + port tertentu di dalam jaringan.

### Mengapa perlu Port Forwarding?
Perangkat di jaringan lokal (server CCTV, server absensi, dashboard monitoring) punya IP private yang tidak bisa diakses langsung dari internet. Dengan port forwarding, kita bisa membuat "pintu khusus" dari internet menuju perangkat tersebut.

### Cara kerjanya (dari contoh di Applewifi)
Request dari internet ke **157.20.233.221 port 8085** → MikroTik menangkap → diteruskan ke **192.168.211.241 port 80** → server lokal merespons → balasan dikirim kembali ke pengirim.

Dari sisi pengirim, mereka hanya tahu alamat 157.20.233.221:8085. Mereka tidak tahu ada server lokal di baliknya.

---

## 4. Menu General di NAT Rule

Menu General adalah **kondisi atau syarat** kapan rule ini aktif. Ibarat satpam yang hanya bertindak kalau ada tamu yang memenuhi kriteria tertentu.

| Field | Fungsi |
|---|---|
| Chain | Jenis NAT: srcnat (keluar) atau dstnat (masuk) |
| Src. Address | Filter berdasarkan IP pengirim |
| Dst. Address | Filter berdasarkan IP tujuan |
| Protocol | Filter berdasarkan protokol (TCP/UDP/ICMP) |
| Src. Port | Filter berdasarkan port pengirim |
| Dst. Port | Filter berdasarkan port tujuan |
| In. Interface | Filter berdasarkan interface masuk |
| Out. Interface | Filter berdasarkan interface keluar |

---

## 5. Apa itu Protocol TCP?

### TCP vs UDP
| | TCP | UDP |
|---|---|---|
| Kepanjangan | Transmission Control Protocol | User Datagram Protocol |
| Koneksi | Ada handshake (3-way handshake) | Langsung kirim tanpa koneksi |
| Keandalan | Data dijamin sampai dan berurutan | Tidak ada jaminan |
| Kecepatan | Lebih lambat | Lebih cepat |
| Cocok untuk | Web (HTTP/HTTPS), email, file transfer | Streaming video, VoIP, DNS, game online |

### Mengapa rule di atas pakai TCP?
Karena port 8085 dan port 80 adalah port untuk akses web (HTTP). Akses web menggunakan protokol TCP karena membutuhkan data yang lengkap dan berurutan, tidak boleh ada yang hilang.

### Kapan pakai UDP di NAT?
Kalau port forwarding untuk layanan seperti VoIP, server game, atau DNS server lokal.

---

## 6. Tentang Port

### Apa itu port?
Port adalah nomor "pintu" pada sebuah perangkat jaringan. Satu IP address bisa punya 65.535 port. Port menentukan aplikasi atau layanan mana yang menerima traffic.

### Port-port yang umum dipakai
| Port | Protokol | Fungsi |
|---|---|---|
| 80 | TCP | HTTP (web biasa) |
| 443 | TCP | HTTPS (web aman) |
| 22 | TCP | SSH (remote akses) |
| 23 | TCP | Telnet |
| 8085 / 8080 / 8443 | TCP | Port alternatif web |
| 53 | UDP/TCP | DNS |
| 3389 | TCP | Remote Desktop (RDP) |
| 554 | TCP/UDP | RTSP (CCTV streaming) |

### Apakah port bisa diisi random?
**Bisa**, tapi ada aturannya:
- Port 0-1023 adalah **well-known ports**, sudah ada fungsi bakunya. Hindari dipakai sembarangan.
- Port 1024-49151 adalah **registered ports**, aman dipakai untuk aplikasi custom.
- Port 49152-65535 adalah **dynamic/private ports**, bebas dipakai.

Port 8085 pada contoh di atas adalah port custom yang dipilih supaya tidak bentrok dengan port 80 yang mungkin sudah dipakai untuk layanan lain di IP public yang sama.

---

## 7. Menu Action di NAT Rule

Menu Action adalah **apa yang dilakukan** MikroTik ketika kondisi di General terpenuhi.

| Field | Fungsi |
|---|---|
| Action | Jenis tindakan (dst-nat, src-nat, masquerade, dll) |
| To Addresses | IP tujuan baru setelah diterjemahkan |
| To Ports | Port tujuan baru setelah diterjemahkan |

### Apakah Action harus mengikuti General?
**Tidak harus sama, tapi harus saling melengkapi.** General adalah kondisi pemicu, Action adalah respons. Keduanya bekerja berpasangan:

- General menangkap: "Ada traffic masuk ke 157.20.233.221 port 8085"
- Action merespons: "Teruskan ke 192.168.211.241 port 80"

### Mengapa To Port bisa berbeda?
Karena di server tujuan, aplikasinya mungkin berjalan di port yang berbeda dari port yang dibuka ke publik. Ini juga bagus untuk keamanan — orang luar tidak tahu port asli server kamu di dalam.

---

## 8. Ringkasan Alur Lengkap

```
INTERNET
    |
    | Request ke 157.20.233.221:8085
    |
[ MikroTik - Firewall NAT DST-NAT ]
    |
    | General: dst address=157.20.233.221, port=8085, protocol=TCP
    | Action: to address=192.168.211.241, to port=80
    |
[ Server Lokal 192.168.211.241:80 ]
    |
    | Respons dikirim kembali ke MikroTik
    |
[ MikroTik menerjemahkan kembali ]
    |
INTERNET (pengirim menerima balasan)
```

---

## 9. Kapan Pakai SRC-NAT vs DST-NAT?

| Situasi | Gunakan |
|---|---|
| Pelanggan mau akses internet | SRC-NAT / Masquerade |
| Mau akses server lokal dari internet | DST-NAT / Port Forwarding |
| Ganti IP public pelanggan yang kena blacklist | SRC-NAT (ganti To Addresses) |
| Buka akses CCTV dari luar | DST-NAT |
| Buka akses dashboard MikroTik dari luar | DST-NAT |

---

*Catatan ini dibuat berdasarkan pembelajaran langsung di lapangan bersama senior NOC Applewifi. Simpan di GitHub portfolio: yugaaajago/My-Learn*
