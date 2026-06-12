# Floating Static Route & Failover - MikroTik CHR Lab

> **Module 2 - Routing Series**  
> Author: Fakih Arta Yuga  
> Tools: MikroTik CHR, VirtualBox  
> Difficulty: Beginner-Intermediate  
> Prerequisites: Module 1 - Static Routing

---

## Daftar Isi

1. [Konsep Dasar](#1-konsep-dasar)
2. [Failover vs Load Balance](#2-failover-vs-load-balance)
3. [Cara Kerja check-gateway=ping](#3-cara-kerja-check-gatewaeping)
4. [Topologi Lab](#4-topologi-lab)
5. [Persiapan VirtualBox](#5-persiapan-virtualbox)
6. [Konfigurasi IP Address](#6-konfigurasi-ip-address)
7. [Konfigurasi Floating Static Route](#7-konfigurasi-floating-static-route)
8. [Verifikasi Routing Table](#8-verifikasi-routing-table)
9. [Simulasi Failover](#9-simulasi-failover)
10. [Troubleshooting Log](#10-troubleshooting-log)
11. [Kesimpulan dan Insight](#11-kesimpulan-dan-insight)

---

## 1. Konsep Dasar

Pada Module 1 kita sudah belajar bahwa static route adalah cara manual memberitahu router jalur menuju network tertentu. Di module ini kita akan membuat dua route menuju tujuan yang sama dengan prioritas berbeda.

Konsep ini disebut **Floating Static Route**, yaitu static route yang "mengambang" dan baru aktif ketika route utama tidak tersedia.

Cara kerjanya:

- Route utama diberi distance kecil (misalnya 1), selalu digunakan selama aktif
- Route backup diberi distance besar (misalnya 10), hanya aktif kalau route utama mati
- MikroTik memantau gateway utama secara berkala menggunakan `check-gateway=ping`
- Kalau gateway utama tidak merespons ping, route utama dinonaktifkan otomatis dan route backup langsung naik menggantikan

---

## 2. Failover vs Load Balance

Dua istilah ini sering membingungkan pemula karena sama-sama melibatkan dua jalur.

### Failover

Satu jalur aktif, satu jalur standby. Traffic hanya melewati jalur utama. Jalur backup baru digunakan ketika jalur utama mati.

```
Kondisi normal:
CHR-A ──── CHR-B (aktif) ────► CHR-D
           CHR-C (standby)

Kondisi CHR-B mati:
CHR-A      CHR-B (mati)
      ──── CHR-C (aktif) ────► CHR-D
```

Keuntungan: Sederhana, mudah diprediksi, cocok untuk koneksi yang butuh stabilitas.

### Load Balance

Kedua jalur aktif bersamaan. Traffic dibagi ke dua jalur sekaligus untuk memaksimalkan penggunaan bandwidth.

```
CHR-A ──── CHR-B (aktif, 50%) ────► CHR-D
      ──── CHR-C (aktif, 50%) ────► CHR-D
```

Keuntungan: Bandwidth lebih optimal karena dua jalur terpakai bersamaan.

### Perbandingan

| Aspek | Failover | Load Balance |
|---|---|---|
| Jumlah jalur aktif | 1 | 2 atau lebih |
| Tujuan utama | Redundansi | Optimasi bandwidth |
| Kompleksitas konfigurasi | Rendah | Lebih tinggi |
| Cocok untuk | Koneksi kritis | Koneksi bandwidth tinggi |
| Di MikroTik | Floating static route | ECMP atau Policy Routing |

Di dunia ISP, load balance digunakan untuk membagi traffic pelanggan antara dua uplink secara bersamaan agar bandwidth keduanya terpakai optimal. Failover digunakan sebagai safety net ketika salah satu uplink gangguan.

---

## 3. Cara Kerja check-gateway=ping

`check-gateway=ping` adalah parameter yang membuat MikroTik secara aktif memantau kondisi gateway menggunakan ICMP ping.

Mekanismenya:

1. MikroTik mengirim ping ke IP gateway secara berkala (default setiap 10 detik)
2. Kalau gateway tidak merespons dalam batas waktu tertentu, route ditandai sebagai tidak aktif
3. Route backup dengan distance lebih besar langsung naik menggantikan
4. Kalau gateway utama kembali merespons, route utama aktif kembali dan route backup kembali standby

Tanpa `check-gateway=ping`, MikroTik tidak akan tahu kalau gateway mati selama koneksi fisik interface masih UP. Route utama tetap dipakai meskipun gateway sudah tidak bisa dijangkau, akibatnya traffic blackhole (paket dikirim tapi tidak sampai).

---

## 4. Topologi Lab

```
                    ┌─────────────────┐
                    │      CHR-B      │
                    │  (Gateway Utama)│
                    │ e1: 10.10.10.2  │
                    │ e2: 10.10.30.1  │
                    └───────┬─────────┘
           net-AB           │           net-BD
┌──────────┐                │                   ┌──────────┐
│  CHR-A   ├────────────────┘                   │  CHR-D   │
│ (Client) │                                    │ (Server) │
│e1:10.10. ├────────────────────────────────────┤e1:10.10. │
│ 10.1/24  │           net-BD                   │ 30.2/24  │
│e2:10.10. ├────────────────┐                   │e2:10.10. │
│ 20.1/24  │                │           net-CD  │ 40.2/24  │
└──────────┘                │                   └──────────┘
           net-AC           │
                    ┌───────┴─────────┐
                    │      CHR-C      │
                    │(Gateway Backup) │
                    │ e1: 10.10.20.2  │
                    │ e2: 10.10.40.1  │
                    └─────────────────┘
```

Topologi sederhana:

```
         [CHR-B] ── Gateway Utama (distance 1)
        /                                      \
[CHR-A]                                        [CHR-D]
        \                                      /
         [CHR-C] ── Gateway Backup (distance 10)
```

**Tabel IP Address:**

| Device | Interface | IP Address | Network | Peran |
|---|---|---|---|---|
| CHR-A | ether1 | 10.10.10.1/24 | net-AB | ke CHR-B (jalur utama) |
| CHR-A | ether2 | 10.10.20.1/24 | net-AC | ke CHR-C (jalur backup) |
| CHR-B | ether1 | 10.10.10.2/24 | net-AB | ke CHR-A |
| CHR-B | ether2 | 10.10.30.1/24 | net-BD | ke CHR-D |
| CHR-C | ether1 | 10.10.20.2/24 | net-AC | ke CHR-A |
| CHR-C | ether2 | 10.10.40.1/24 | net-CD | ke CHR-D |
| CHR-D | ether1 | 10.10.30.2/24 | net-BD | ke CHR-B |
| CHR-D | ether2 | 10.10.40.2/24 | net-CD | ke CHR-C |

---

## 5. Persiapan VirtualBox

### Kebutuhan

- VirtualBox versi terbaru
- 4 file CHR image (.vmdk)
- RAM minimal 1GB total (256MB per CHR)

### Pengaturan Network Adapter

**CHR-A:**
- Adapter 1: Internal Network → `net-AB`
- Adapter 2: Internal Network → `net-AC`

**CHR-B:**
- Adapter 1: Internal Network → `net-AB`
- Adapter 2: Internal Network → `net-BD`

**CHR-C:**
- Adapter 1: Internal Network → `net-AC`
- Adapter 2: Internal Network → `net-CD`

**CHR-D:**
- Adapter 1: Internal Network → `net-BD`
- Adapter 2: Internal Network → `net-CD`

---

## 6. Konfigurasi IP Address

### CHR-A

```
/ip address add address=10.10.10.1/24 interface=ether1
/ip address add address=10.10.20.1/24 interface=ether2
```

### CHR-B

```
/ip address add address=10.10.10.2/24 interface=ether1
/ip address add address=10.10.30.1/24 interface=ether2
```

### CHR-C

```
/ip address add address=10.10.20.2/24 interface=ether1
/ip address add address=10.10.40.1/24 interface=ether2
```

### CHR-D

```
/ip address add address=10.10.30.2/24 interface=ether1
/ip address add address=10.10.40.2/24 interface=ether2
```

### Verifikasi

Jalankan di semua CHR:

```
/ip address print
```

### Test Koneksi Langsung

Sebelum menambahkan route, pastikan koneksi antar CHR yang terhubung langsung sudah berfungsi.

Dari CHR-A:
```
/tool ping 10.10.10.2 count=3
/tool ping 10.10.20.2 count=3
```

Dari CHR-D:
```
/tool ping 10.10.30.1 count=3
/tool ping 10.10.40.1 count=3
```

Semua harus reply karena masih satu network langsung.

---

## 7. Konfigurasi Floating Static Route

### CHR-A (konfigurasi terpenting)

Di sinilah floating static route diterapkan. Dua route ke tujuan yang sama dengan distance berbeda.

```
/ip route add dst-address=10.10.30.0/24 gateway=10.10.10.2 distance=1 check-gateway=ping
/ip route add dst-address=10.10.30.0/24 gateway=10.10.20.2 distance=10 check-gateway=ping
/ip route add dst-address=10.10.40.0/24 gateway=10.10.10.2 distance=1 check-gateway=ping
/ip route add dst-address=10.10.40.0/24 gateway=10.10.20.2 distance=10 check-gateway=ping
```

Penjelasan:

| Route | Gateway | Distance | Peran |
|---|---|---|---|
| 10.10.30.0/24 via 10.10.10.2 | CHR-B | 1 | Jalur utama |
| 10.10.30.0/24 via 10.10.20.2 | CHR-C | 10 | Jalur backup |
| 10.10.40.0/24 via 10.10.10.2 | CHR-B | 1 | Jalur utama |
| 10.10.40.0/24 via 10.10.20.2 | CHR-C | 10 | Jalur backup |

### CHR-B

```
/ip route add dst-address=10.10.20.0/24 gateway=10.10.10.1
/ip route add dst-address=10.10.40.0/24 gateway=10.10.30.2
```

### CHR-C

```
/ip route add dst-address=10.10.10.0/24 gateway=10.10.20.1
/ip route add dst-address=10.10.30.0/24 gateway=10.10.40.2
```

### CHR-D

```
/ip route add dst-address=10.10.10.0/24 gateway=10.10.30.1
/ip route add dst-address=10.10.20.0/24 gateway=10.10.40.1
```

---

## 8. Verifikasi Routing Table

Jalankan di CHR-A:

```
/ip route print
```

Output yang diharapkan:

```
Flags: D - DYNAMIC; A - ACTIVE; c - CONNECT; s - STATIC
#    DST-ADDRESS       GATEWAY       ROUTING-TABLE  DISTANCE
0 DAc 10.10.10.0/24   ether1        main           0
1 DAc 10.10.20.0/24   ether2        main           0
2 DAs 10.10.30.0/24   10.10.10.2    main           1    ← utama (Active)
3  As 10.10.30.0/24   10.10.20.2    main           10   ← backup (standby)
4 DAs 10.10.40.0/24   10.10.10.2    main           1    ← utama (Active)
5  As 10.10.40.0/24   10.10.20.2    main           10   ← backup (standby)
```

Perhatikan perbedaan flag:
- Route utama punya flag `A` (Active) karena sedang digunakan
- Route backup tidak punya flag `A` karena sedang standby menunggu jalur utama mati

---

## 9. Simulasi Failover

### Langkah 1 - Jalankan ping continuous dari CHR-A

```
/tool ping 10.10.30.2
```

Biarkan ping berjalan tanpa dihentikan.

### Langkah 2 - Matikan CHR-B

Pergi ke VirtualBox, klik kanan VM CHR-B → Close → Power Off.

### Langkah 3 - Amati hasil ping

Yang akan terjadi:

```
SEQ  HOST          SIZE  TTL  TIME    STATUS
20   10.10.30.2    56    64   3ms           ← masih lewat CHR-B
21   10.10.30.2                      timeout ← CHR-B baru mati
22   10.10.30.2                      timeout ← MikroTik deteksi gateway mati
...  (beberapa timeout saat MikroTik switch ke backup)
45   10.10.30.2    56    63   5ms           ← sudah lewat CHR-C
46   10.10.30.2    56    63   4ms           ← failover berhasil
```

Ada jeda beberapa detik timeout saat failover terjadi. Ini normal karena MikroTik butuh waktu untuk mendeteksi gateway mati melalui `check-gateway=ping`.

### Langkah 4 - Cek routing table setelah failover

```
/ip route print
```

Output setelah CHR-B mati:

```
#    DST-ADDRESS       GATEWAY       ROUTING-TABLE  DISTANCE
0 DAc 10.10.10.0/24   ether1        main           0
1 DAc 10.10.20.0/24   ether2        main           0
2  As 10.10.30.0/24   10.10.10.2    main           1    ← utama (tidak Active)
3 DAs 10.10.30.0/24   10.10.20.2    main           10   ← backup (sekarang Active)
4  As 10.10.40.0/24   10.10.10.2    main           1    ← utama (tidak Active)
5 DAs 10.10.40.0/24   10.10.20.2    main           10   ← backup (sekarang Active)
```

Route utama kehilangan flag `A` dan route backup naik menjadi Active.

### Langkah 5 - Hidupkan kembali CHR-B

Nyalakan kembali VM CHR-B di VirtualBox. Amati ping di CHR-A, setelah CHR-B kembali online, traffic akan otomatis kembali lewat jalur utama dan route backup kembali standby.

---

## 10. Troubleshooting Log

### Masalah 1: Ping timeout terus meski route sudah ditambah

Penyebab: Route di CHR-B, CHR-C, atau CHR-D belum ditambahkan. Routing harus dua arah.

Solusi: Pastikan semua CHR sudah dikonfigurasi route-nya, bukan hanya CHR-A.

### Masalah 2: Failover tidak terjadi meski CHR-B dimatikan

Penyebab: Lupa menambahkan `check-gateway=ping` di route utama.

Solusi: Hapus route lama dan tambahkan ulang dengan parameter `check-gateway=ping`.

```
/ip route remove [find dst-address=10.10.30.0/24 distance=1]
/ip route add dst-address=10.10.30.0/24 gateway=10.10.10.2 distance=1 check-gateway=ping
```

### Masalah 3: Jeda failover terlalu lama

Penyebab: Default interval check-gateway cukup lambat untuk lab.

Penjelasan: Ini normal di lingkungan production. Di lab bisa terasa lama karena kita menunggu real-time. Di jaringan nyata, jeda ini masih bisa diterima untuk sebagian besar use case.

---

## 11. Kesimpulan dan Insight

### Apa yang Dipelajari

- Floating static route adalah dua route ke tujuan yang sama dengan distance berbeda
- Route dengan distance lebih kecil selalu diprioritaskan selama gateway-nya aktif
- `check-gateway=ping` membuat MikroTik memantau gateway secara aktif
- Tanpa `check-gateway=ping`, failover tidak akan terjadi meski gateway sudah mati
- Ada jeda beberapa detik saat failover, ini normal karena butuh waktu deteksi

### Perbedaan Failover dan Load Balance

Failover hanya menggunakan satu jalur pada satu waktu. Load balance menggunakan dua jalur bersamaan. Failover lebih sederhana dan cocok untuk kebutuhan redundansi. Load balance lebih kompleks dan cocok untuk optimasi bandwidth.

### Kaitan dengan Dunia Nyata

Di jaringan ISP seperti Applewifi, konsep ini digunakan pada level yang lebih besar. Ketika uplink Lintasarta gangguan, traffic pelanggan otomatis berpindah ke uplink Iforte tanpa perlu intervensi manual dari NOC. Konfigurasi yang dibuat senior ketika menambahkan route `/32` ke IP spesifik server juga menggunakan prinsip yang sama, yaitu mengarahkan traffic ke gateway yang tepat berdasarkan tujuan.

### Next Module

Module 3 akan membahas **OSPF (Open Shortest Path First)**, yaitu dynamic routing protocol yang digunakan di jaringan skala besar. Dengan OSPF, router bisa saling berbagi informasi route secara otomatis tanpa perlu konfigurasi manual satu per satu.

---

*Lab ini adalah bagian dari seri belajar mandiri menuju Network Architect.*  
*Repository: [yugaaajago/My-Learn](https://github.com/yugaaajago/My-Learn)*
