# Static Routing - MikroTik CHR Lab

> **Module 1 - Routing Series**  
> Author: Fakih Arta Yuga  
> Tools: MikroTik CHR, VirtualBox  
> Difficulty: Beginner

---

## Daftar Isi

1. [Apa itu Routing?](#1-apa-itu-routing)
2. [Routing Table](#2-routing-table)
3. [Jenis-jenis Route](#3-jenis-jenis-route)
4. [Distance vs Hop Count](#4-distance-vs-hop-count)
5. [Topologi Lab](#5-topologi-lab)
6. [Persiapan VirtualBox](#6-persiapan-virtualbox)
7. [Konfigurasi IP Address](#7-konfigurasi-ip-address)
8. [Konfigurasi Static Route](#8-konfigurasi-static-route)
9. [Verifikasi dan Testing](#9-verifikasi-dan-testing)
10. [Troubleshooting Log](#10-troubleshooting-log)
11. [Kesimpulan dan Insight](#11-kesimpulan-dan-insight)

---

## 1. Apa itu Routing?

Routing adalah proses pengambilan keputusan oleh router untuk menentukan jalur terbaik dalam mengirimkan paket data dari sumber ke tujuan.

Bayangkan kamu adalah seorang pak pos. Kamu punya buku alamat (routing table). Setiap kali ada surat masuk (paket data), kamu cek buku alamat dan tentukan:

- Surat ke Jakarta → kirim lewat jalur A
- Surat ke Surabaya → kirim lewat jalur B
- Surat ke alamat yang tidak ada di buku → kirim ke kantor pusat (default route)

Router bekerja persis seperti itu, setiap paket yang masuk akan dicek IP tujuannya, lalu dicocokkan dengan routing table untuk menentukan lewat interface mana paket tersebut dikirim.

---

## 2. Routing Table

Routing table adalah daftar berisi informasi jalur yang diketahui oleh router. Setiap baris di routing table disebut satu entry route.

Cara melihat routing table di MikroTik:

```
/ip route print
```

Contoh output:

```
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT; s - STATIC
#    DST-ADDRESS       GATEWAY         ROUTING-TABLE   DISTANCE
0 DAc 192.168.10.0/24  ether1          main            0
1 DAs 192.168.20.0/24  192.168.10.2    main            1
2 DAs 0.0.0.0/0        10.0.0.1        main            1
```

**Penjelasan kolom:**

| Kolom | Keterangan |
|---|---|
| Flags | Status route: D=Dynamic, A=Active, c=Connected, s=Static |
| DST-ADDRESS | Network tujuan beserta prefix length |
| GATEWAY | Lewat mana paket dikirim (IP next-hop atau interface) |
| DISTANCE | Tingkat kepercayaan route, makin kecil makin diprioritaskan |

**Cara MikroTik memilih route:**

1. Cari entry yang paling spesifik (prefix terpanjang) yang cocok dengan IP tujuan
2. Kalau ada dua route ke tujuan yang sama, pilih yang distance-nya lebih kecil
3. Kalau tidak ada yang cocok sama sekali, gunakan default route `0.0.0.0/0`
4. Kalau tidak ada default route, paket dibuang (drop)

---

## 3. Jenis-jenis Route

### Connected Route (flag: c)

Route yang terbentuk otomatis ketika kamu menambahkan IP address ke sebuah interface. Router langsung tahu bahwa network tersebut terhubung langsung ke dirinya.

```
/ip address add address=192.168.10.1/24 interface=ether1
```

Setelah perintah di atas, otomatis muncul connected route ke `192.168.10.0/24` dengan distance 0.

### Static Route (flag: s)

Route yang ditambahkan secara manual oleh administrator. Digunakan untuk memberitahu router cara mencapai network yang tidak terhubung langsung.

```
/ip route add dst-address=192.168.20.0/24 gateway=192.168.10.2
```

### Default Route

Static route khusus dengan tujuan `0.0.0.0/0`, artinya "semua paket yang tidak cocok dengan route manapun, kirim ke sini". Biasanya mengarah ke gateway ISP.

```
/ip route add dst-address=0.0.0.0/0 gateway=10.0.0.1
```

### Dynamic Route (flag: D)

Route yang dipelajari otomatis melalui protokol routing dinamis seperti OSPF, BGP, atau RIP. Akan dipelajari di module berikutnya.

---

## 4. Distance vs Hop Count

Ini dua konsep yang berbeda dan sering membingungkan pemula.

### Distance (Administrative Distance)

Distance adalah **tingkat kepercayaan** terhadap sebuah route, bukan jarak fisik. Nilai ini digunakan untuk memilih route terbaik ketika ada dua atau lebih route menuju tujuan yang sama.

| Jenis Route | Default Distance |
|---|---|
| Connected | 0 |
| Static | 1 |
| OSPF | 110 |
| BGP | 200 |

Semakin kecil distance, semakin tinggi prioritasnya.

**Contoh penggunaan:** Kamu punya dua route ke `192.168.20.0/24`:
- Lewat ether1 dengan distance 1 (jalur utama)
- Lewat ether2 dengan distance 10 (jalur backup)

MikroTik akan selalu pakai ether1. Kalau ether1 mati dan menggunakan `check-gateway=ping`, secara otomatis beralih ke ether2. Ini disebut **floating static route**.

### Hop Count

Hop count adalah **jumlah router yang dilewati** paket dari sumber ke tujuan. Ini terlihat di traceroute, bukan di routing table.

```
/tool traceroute 192.168.20.2
```

Contoh output:
```
  1  192.168.10.2   2ms   ← hop 1 (CHR-B)
  2  192.168.20.2   4ms   ← hop 2 (CHR-C / tujuan)
```

**Kesimpulan:** Distance adalah soal prioritas route di dalam satu router. Hop count adalah soal berapa router yang dilalui paket di jaringan.

---

## 5. Topologi Lab

```
┌─────────────┐          ┌─────────────┐          ┌─────────────┐
│    CHR-A    │          │    CHR-B    │          │    CHR-C    │
│             │          │             │          │             │
│ ether1      ├──────────┤ ether2      │          │             │
│ 192.168.    │ net-AB   │ 192.168.    │          │             │
│ 10.1/24     │          │ 10.2/24     │          │             │
│             │          │             │          │             │
│             │          │ ether3      ├──────────┤ ether1      │
│             │          │ 192.168.    │ net-BC   │ 192.168.    │
│             │          │ 20.1/24     │          │ 20.2/24     │
└─────────────┘          └─────────────┘          └─────────────┘

Network AB : 192.168.10.0/24
Network BC : 192.168.20.0/24

Tujuan : CHR-A bisa ping CHR-C melewati CHR-B menggunakan static route
```

**Peran masing-masing CHR:**

| Device | Peran | Interface | IP Address |
|---|---|---|---|
| CHR-A | End router kiri | ether1 | 192.168.10.1/24 |
| CHR-B | Router tengah (transit) | ether2 | 192.168.10.2/24 |
| CHR-B | Router tengah (transit) | ether3 | 192.168.20.1/24 |
| CHR-C | End router kanan | ether1 | 192.168.20.2/24 |

---

## 6. Persiapan VirtualBox

### Kebutuhan

- VirtualBox versi terbaru
- 3 file CHR image (.vmdk)
- RAM minimal 256MB per CHR

### Pengaturan Network Adapter

Buka Settings masing-masing VM di VirtualBox, tab Network:

**CHR-A:**
- Adapter 1: Internal Network → `net-AB`

**CHR-B:**
- Adapter 1: Internal Network → `net-AB`
- Adapter 2: Internal Network → `net-BC`

**CHR-C:**
- Adapter 1: Internal Network → `net-BC`

> Internal Network di VirtualBox membuat jaringan terisolasi antar VM. VM yang terhubung ke nama Internal Network yang sama bisa saling komunikasi, tapi tidak tembus ke internet maupun host.

---

## 7. Konfigurasi IP Address

### CHR-A

```
/ip address add address=192.168.10.1/24 interface=ether1
```

Verifikasi:

```
/ip address print
```

Output yang diharapkan:
```
# ADDRESS            NETWORK      INTERFACE
0 192.168.10.1/24   192.168.10.0  ether1
```

### CHR-B

```
/ip address add address=192.168.10.2/24 interface=ether2
/ip address add address=192.168.20.1/24 interface=ether3
```

Verifikasi:

```
/ip address print
```

Output yang diharapkan:
```
# ADDRESS            NETWORK      INTERFACE
0 192.168.10.2/24   192.168.10.0  ether2
1 192.168.20.1/24   192.168.20.0  ether3
```

### CHR-C

```
/ip address add address=192.168.20.2/24 interface=ether1
```

Verifikasi:

```
/ip address print
```

Output yang diharapkan:
```
# ADDRESS            NETWORK      INTERFACE
0 192.168.20.2/24   192.168.20.0  ether1
```

---

## 8. Konfigurasi Static Route

Sebelum menambahkan route, pahami logikanya terlebih dahulu:

- CHR-A hanya tahu network `192.168.10.0/24` (connected langsung)
- CHR-A tidak tahu cara menuju `192.168.20.0/24`
- CHR-A perlu diberi tahu: "Kalau mau ke `192.168.20.0/24`, kirim ke `192.168.10.2` (CHR-B)"

Hal yang sama berlaku sebaliknya untuk CHR-C.

CHR-B tidak perlu ditambahkan route karena dia sudah terhubung langsung ke kedua network.

### Tambah Route di CHR-A

```
/ip route add dst-address=192.168.20.0/24 gateway=192.168.10.2
```

Verifikasi:

```
/ip route print
```

Output yang diharapkan:
```
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT; s - STATIC
#    DST-ADDRESS       GATEWAY        ROUTING-TABLE  DISTANCE
0 DAc 192.168.10.0/24  ether1         main           0
1 DAs 192.168.20.0/24  192.168.10.2   main           1
```

### Tambah Route di CHR-C

```
/ip route add dst-address=192.168.10.0/24 gateway=192.168.20.1
```

Verifikasi:

```
/ip route print
```

Output yang diharapkan:
```
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT; s - STATIC
#    DST-ADDRESS       GATEWAY        ROUTING-TABLE  DISTANCE
0 DAc 192.168.20.0/24  ether1         main           0
1 DAs 192.168.10.0/24  192.168.20.1   main           1
```

---

## 9. Verifikasi dan Testing

### Test Koneksi Antar CHR

**Dari CHR-A ke CHR-C:**

```
/tool ping 192.168.20.2 count=5
```

Output yang diharapkan:
```
SEQ HOST          SIZE TTL TIME   STATUS
0   192.168.20.2  56   63  2ms
1   192.168.20.2  56   63  3ms
2   192.168.20.2  56   63  2ms
3   192.168.20.2  56   63  4ms
4   192.168.20.2  56   63  3ms
sent=5 received=5 packet-loss=0%
```

**Dari CHR-C ke CHR-A:**

```
/tool ping 192.168.10.1 count=5
```

### Traceroute untuk Melihat Hop

Dari CHR-A:

```
/tool traceroute 192.168.20.2
```

Output yang diharapkan:
```
  1  192.168.10.2   2ms    ← CHR-B (router transit)
  2  192.168.20.2   4ms    ← CHR-C (tujuan)
```

Ini membuktikan paket melewati 2 hop: CHR-A → CHR-B → CHR-C.

### Simulasi Route Mati

Untuk memahami pentingnya routing, coba hapus route di CHR-A:

```
/ip route remove [find dst-address=192.168.20.0/24]
```

Lalu ping lagi ke CHR-C:

```
/tool ping 192.168.20.2 count=3
```

Hasilnya akan `no route to host`. Ini membuktikan bahwa tanpa route, paket tidak bisa sampai meskipun koneksi fisik masih ada.

Tambahkan kembali route-nya:

```
/ip route add dst-address=192.168.20.0/24 gateway=192.168.10.2
```

---

## 10. Troubleshooting Log

### Masalah yang Ditemui Saat Lab

**Masalah 1: Muncul IP ekstra di CHR-B (192.168.226.x)**

Penyebab: VirtualBox memberikan IP DHCP otomatis di ether1 karena adapter pertama terhubung ke NAT atau Bridged secara tidak sengaja.

Solusi: Biarkan saja, tidak mempengaruhi lab. Atau hapus dengan:
```
/ip address remove [find address~"192.168.226"]
```

**Masalah 2: Ping tetap timeout meski route sudah ditambah**

Penyebab: Route hanya ditambah di satu sisi. Misalnya hanya di CHR-A tapi tidak di CHR-C.

Solusi: Routing harus dua arah. CHR-A tahu cara ke CHR-C, CHR-C juga harus tahu cara balik ke CHR-A.

**Masalah 3: `no route to` meskipun IP address sudah benar**

Penyebab: Gateway yang diisi di static route tidak reachable, misalnya typo IP gateway.

Solusi: Pastikan ping ke gateway berhasil dulu sebelum menambahkan route.

---

## 11. Kesimpulan dan Insight

### Apa yang Dipelajari

- Router tidak bisa mengirim paket ke network yang tidak dikenalnya
- Static route adalah cara manual memberitahu router jalur menuju network tertentu
- Routing harus bersifat dua arah agar komunikasi bisa terjadi
- Distance bukan hop count. Distance adalah prioritas route, hop count adalah jumlah router yang dilewati
- Prefix `/32` berarti satu IP spesifik, bukan satu network

### Kaitan dengan Dunia Nyata

Kasus ini identik dengan troubleshooting nyata di lapangan. Ketika ada pelanggan ISP yang tidak bisa mengakses website tertentu padahal situs lain lancar, kemungkinan besar penyebabnya adalah routing ke IP spesifik server tersebut yang tidak tepat. Solusinya adalah menambahkan static route `/32` ke IP server tersebut lewat gateway uplink yang benar, persis seperti yang dilakukan di kasus nyata Inspektorat Batang.

### Next Module

Module 2 akan membahas **Floating Static Route** dan **Failover**, yaitu bagaimana membuat jaringan otomatis berpindah jalur ketika jalur utama mati, menggunakan fitur `check-gateway=ping` di MikroTik.

---

*Lab ini adalah bagian dari seri belajar mandiri menuju Network Architect.*  
*Repository: [yugaaajago/My-Learn](https://github.com/yugaaajago/My-Learn)*
