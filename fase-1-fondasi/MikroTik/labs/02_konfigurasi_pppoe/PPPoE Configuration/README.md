# Lab 02 — PPoE Configuration
**Tanggal:** 29 Mei 2026 | **Status:** ✅ Selesai

---

## Tujuan
Tujuan dari praktik ini adalah untuk menguji pemahaman pada materi konfigurasi PPPoE, bukan hanya materi saja namun dengan praktik langsung. Disini saya belajar cara mengkonfigurasi PPPoE Server dan PPPoE Client secara langsung, konfigurasi PPPoE Profile (20Mbps dan 10Mbps), PPP Secret pada tiap pelanggan, ada pula cara tes bandwidth untuk menguji kecepatan yang sudah dikonfigurasi. 

Pada materi ini saya menggunakan 3 MikroTik CHR pada VirtualBox dan saya setting melalui winbox.

## Topologi
```
+------------+        +------------+        +------------+
|   CHR-B    | <----- |   CHR-A    | -----> |   CHR-C    |
+------------+        +------------+        +------------+
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
Menambahkan DHCP Client
```
ip dhcp-client add interface=ether1
```
Menambahkan IP Pool
```
ip pool add name=vip-20Mbps ranges=10.10.10.10-10.10.10.254
ip pool add name=member-10Mbps ranges=10.10.20.10-10.10.10.254
```
Setup DNS
```
ip dns set servers=192.168.226.1,8.8.8.8 allow-remote-requests=yes
```
Konfigurasi PPP Profile
```
ppp profile add name=vip-20Mbps local-address=10.10.10.1 remote-address=vip-20Mbps dns-server=8.8.8.8 rate-limit=20M/20M
ppp profile add name=member-10Mbps local-address=10.10.20.1 remote-address=member-10Mbps dns-server=8.8.8.8 rate-limit=10M/10M
```
Konfigurasi PPPoE Server
```
interface pppoe-server server add default-profile=vip-20Mbps disabled=no interface=ether2 service-name=kalisari
interface pppoe-server server add default-profile=member-10Mbps disabled=no interface=ether3 service-name=pagilaran
```
Menambahkan firewall NAT
```
ip firewall nat add chain=srcnat action=masquerade out-interface=ether1
```
Konfigurasi PPP Secret
```
ppp secret add name=yugaa password=12345678 profile=vip-20Mbps
ppp secret add name=arkan password=12345678 profile=member-10Mbps
```
Matikan auntentikasi Bandwidth-test
```
tool bandwidth-server set authenticate=no
```
&ensp;
**CHR-B:**<br>
Mengganti nama perangkat
```
system identity set name=CHR-B
```
Konfigurasi PPPoE Client
```
interface pppoe-client add name=pppoe-batang user=yugaa password=12345678 disabled=no interface=ether1
```
Menambahkan route
```
ip route add gateway=pppoe-batang
```
&ensp;
**CHR-C:**<br>
Mengganti nama perangkat
```
system identity set name=CHR-C
```
Konfigurasi PPPoE Client
```
interface pppoe-client add name=pppoe-batang user=arkan password=12345678 disabled=no interface=ether1
```
Menambahkan route
```
ip route add gateway=pppoe-batang
```

## Testing
Cek apakah sudah dapat IP otomatis pada CHR-B dan CHR-C
```
ip address print
```
Lanjut ping gateway
```
ping 10.10.10.1 (CHR-B)
ping 10.10.20.1 (CHR-C)
```
Tes bandwidth
```
tool bandwidth-test address=10.10.10.1 direction=receive duration=10 (CHR-B)
tool bandwidth-test address=10.10.20.1 direction=receive duration=10 (CHR-C)
```

## Hasil
✅ CHR-B dan CHR-C mendapatkan ip secara otomatis melalui username dan password pada PPPoE Client<br>
✅ Hasil tes bandwidth sesuai dengan yang dikonfigurasi (20Mbps untuk user yugaa dan 10Mbps untuk user arkan)

## Yang Dipelajari
- Cara konfigurasi PPPoE
- Cara membatasi bandwidth untuk client
- cara menguji kecepatan bandwidth

## File
- `pppoe-server-batang.rsc` → config CHR-A
- `pppoe-client-yugaa.rsc` → config CHR-B
- `pppoe-client-arkan.rsc` → config CHR-C