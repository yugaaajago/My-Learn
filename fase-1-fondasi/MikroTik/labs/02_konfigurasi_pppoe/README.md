
# Lab 02 — Konfigurasi PPPoE

Jadi pada tahap ini saya telah mempraktikkan penggunaan pppoe dengan 3 MikroTik CHR. Dimana 1 MikroTik menjadi pusat yang memberikan akses internet kepada Mikrotik lainya.

## Topologi
CHR-B & CHR-C (PPPoE Client) → CHR-A (PPPoE Server) → Internet

## Yang Dikonfigurasi
- IP Pool per wilayah
- PPPoE Profile (VIP 20Mbps & Member 10Mbps)  
- PPPoE Server di ether2 & ether3
- PPP Secrets per pelanggan

## Hasil
✅ 2 pelanggan konek PPPoE simultan
✅ Simulasi isolir pelanggan berhasil
Router A = pppoe-pusat-smg

### ip pool
| nama | pool |
|---|---|
| member-10Mbps | 10.10.10.10-10.10.10.254 |
| vip-20Mbps | 10.10.20.10-10.10.20.254 |

### ppp profile
|nama|local-address|remote-address|rate-limit|dns-server|only-one|
|---|---|---|---|---|---|
|vip-20Mbps|10.10.20.1|vip-20Mbps|20M/20M|8.8.8.8|no|
|Member-10Mbps|10.10.10.1|member-10Mbps|10M/10M|8.8.8.8|no|

### pppoe-server

|service-name|interface|default-profile|disabled|
|---|---|---|---|
|kalisari|ether2|vip-20Mbps|no|
|pagilaran|ether3|Member-10Mbps|no|

### ppp secret

|name|service|password|profile|
|---|---|---|---|
|yugaa|pppoe|12345678|vip-20Mbps|
|arkan|pppoe|12345678|Member-10Mbps|

&nbsp;

Router B = pppoe-client-kalisari

### pppoe-client

|name|interface|user|password|
|---|---|---|---|
|pppoe-pusat-smg|ether1|yugaa|12345678|

&nbsp;

Router C = pppoe-client-pagilaran

### pppoe-client

|name|interface|user|password|
|---|---|---|---|
|pppoe-pusat-smg|ether1|arkan|12345678|