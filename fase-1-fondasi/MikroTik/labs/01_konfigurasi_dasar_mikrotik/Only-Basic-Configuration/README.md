# Lab 01 — Basic-Configuration
**Tanggal:** 30 Mei 2026 | **Status:** ✅ Selesai

---

## Tujuan
Tujuan dari praktik ini adalah untuk mengetest pemahaman pada konfigurasi dasar mikrotik, bukan hanya materi saja namun dengan praktik langsung. Disini saya belajar cara menghubungkan beberapa router secara static dan secara dynamic menggunakan dhcp server dan dhcp client. Untuk mengujinya saya mencoba ping antar client dan memastikan hasilnya TTL bukan timeout.

Pada materi ini saya menggunakan 3 MikroTik CHR pada VirtualBox dan saya setting melalui winbox.

## Topologi
```
            +----------+
            | Internet |
            +----------+
                 |
             +-------+
             | CHR-A | (Gateway/Router Utama)
             +-------+ 
            /         \
        (Static)     (DHCP)
           |           |
       +-------+    +-------+
       | CHR-B |    | CHR-C |
       +-------+    +-------+
```

## Perangkat & Adapter
| Perangkat | Adapter 1 | Adapter 2 | Adapter 3 |
|-----------|-----------|-----------|-----------|
| CHR-A     | Bridge    | intnet5   | intnet6   |
| CHR-B     | intnet5    | Host-Only   | -   |
| CHR-C     | intnet6    | Host-Only   | -   |

## Konfigurasi
**CHR-A:**<br>
Mengganti nama perangkat
```
system identity set name=CHR-A
```
Menambahkan alamat IP 
```
ip address add address=192.168.226.57/24 interface=ether1 (Internet)
ip address add address=192.168.10.1/24 interface=ether2
ip address add address=192.168.20.1/24 interface=ether3
```
Setup DNS
```
ip dns set servers=192.168.226.1,8.8.8.8 allow-remote-requests=yes
```
Setup DHCP-Server untuk CHR-C
```
ip dhcp-server setup 
[interface=ether3]
[network=192.168.20.0/24]
[gateway=192.168.20.1]
[address-to-give-out=192.168.20.2-192.168.20.254]
[dns=yes 
192.168.226.1,8.8.8.8]
```
Menambahkan firewall NAT
```
ip firewall nat add chain=srcnat action=masquerade out-interface=ether1
```
Menambahkan route static
```
ip route add gateway=192.168.226.1
```
&ensp;
**CHR-B:**<br>
Mengganti nama perangkat
```
system identity set name=CHR-B
```
Menambahkan alamat IP
```
ip address add address=192.168.10.2/24 interface=ether1
ip address add address=192.168.100.1/24 interface=ether2
```
Menambahkan route static
```
ip route add gateway=192.168.10.1
```
&ensp;
**CHR-C:**<br>
Mengganti nama perangkat
```
system identity set name=CHR-C
```
Menambahkan DHCP-Client
```
ip dhcp-client add interface=ether1
```
Menambahkan alamat IP
```
ip address add address=192.168.200.1 interface=ether2
```
## Hasil
✅ Client (CHR) B dan C bisa ping ke Router CHR-A <br>
✅ Sesama Client bisa ping satu sama lain

## Yang Dipelajari
- Perbedaan static route vs DHCP client — kapan pakai yang mana
- NAT masquerade adalah kunci agar traffic dari jaringan private 
  bisa keluar ke internet
- DHCP server membutuhkan pool, gateway, dan DNS agar bisa 
  berfungsi dengan benar
- Alur data: CHR-B/C → CHR-A → Internet (semua lewat satu gateway)

## Kendala & Solusi
| Kendala | Solusi |
|---------|--------|
| kesalahan pengisian ip yang mengakibatkan gagalnya koneksi | mencari kesalahan konfigurasi, dan memperbaiki kesalahan pada ip |

## File
- `basic-configuration-chr-a.rsc` → config CHR-A
- `basic-configuration-chr-b.rsc` → config CHR-B
- `basic-configuration-chr-c.rsc` → config CHR-C