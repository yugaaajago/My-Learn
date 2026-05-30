# Only Basic Configuration
## Kata Pengantar

Hallo, saya jelaskan sedikit apa saja yang saya konfigurasi pada materi ini. Jadi saya mengkonfigurasi IP Address, Static Route, DHCP-Server, dan DHCP-Client.

Untuk konfigurasinya adalah CHR-B disetting IP Static dari CHR-A, CHR-C Setting DHCP-Client.

Pada materi ini saya menggunakan 3 MikroTik CHR yang saya jalankan pada VirtualBox. berikut adalah detail MikroTik CHR saya.

| Nama | Adapter 1 | Adapter 2 | Adapter 3 |
|---|---|---|---|
| CHR-A | Bridge | intnet5 | intnet6 |
| CHR-B | intnet5 | Host-Only | - |
| CHR-C | intnet6 | Hsot-Only | - |

## Topologi

[CHR-B] <---(Static)---> [CHR-A] <---(Dynamic)---> [CHR-C] 

## IP Address

| Nama | IP Address | Interface | Keterangan |
|---|---|---|---|
| CHR-A | 192.168.226.57/24 | Ether1 | Dari internet |
| CHR-A | 192.168.10.1/24 | Ether2 | Static IP |
| CHR-A | 192.168.20.1/24 | Ether3 | DHCP-Server |
| CHR-B | 192.168.10.2/24 | Ether1 | Setting IP manual |
| CHR-B | 192.168.100.1/24 | Ether2 | - |
| CHR-C | 192.168.20.254/24 | Ether1 | DHCP-Client |
| CHR-C | 192.168.200.1/24 | Ether2 | - |
