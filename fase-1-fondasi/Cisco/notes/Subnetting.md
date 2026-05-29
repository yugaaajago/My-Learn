<<<<<<< HEAD


# IP Address
Apa itu IP Address? Bayangin kamu tinggal di sebuah kota besar. Setiap rumah punya alamat unik supaya kurir tahu harus ke mana mengantarkan paket. Nah, IP Address adalah alamat rumah untuk setiap perangkat di jaringan.

| Nama kelas | IP Private | IP Publik | Penggunaan |
|---|---|---|---|
| Kelas A | 10.0.0.0 – 10.255.255.255 | 1.0.0.0 – 9.255.255.255 dan 11.0.0.0 – 127.255.255.255 *(kecuali IP loopback 127.0.0.1) |  Skala jaringan sangat besar (skala internasional atau perusahaan multinasional). |
| Kelas B | 172.16.0.0 – 172.31.255.255 | 128.0.0.0 – 172.15.255.255 dan 172.32.0.0 – 191.255.255.255 |  Skala jaringan menengah, seperti kampus atau perusahaan besar. |
| Kelas C | 192.168.0.0 – 192.168.255.255 | 192.0.0.0 – 192.167.255.255 dan 192.169.0.0 – 223.255.255.255 | Skala jaringan kecil, seperti warnet, kantor cabang, atau jaringan rumah. |

| Nama Kelas | Rentang IP | Penggunaan |
|----|----|----|
| Kelas D | 224.0.0.0 – 239.255.255.255 | Tidak dibagi menjadi publik/privat karena dikhususkan untuk transmisi multicast dalam jaringan. |
| Kelas E | 240.0.0.0 – 255.255.255.255 | Dicadangkan oleh IANA secara eksklusif untuk keperluan eksperimen, penelitian (Research and Development), dan masa depan. |

# Subnetting
Subnetting itu ibarat membagi komplek perumahan besar menjadi beberapa blok kecil. Tujuannya supaya jaringan lebih rapi, efisien, dan aman.
Contoh soal nyata seperti di dunia kerja:
Kamu dapat IP 192.168.10.0/24 dan diminta bagi menjadi 4 subnet untuk 4 divisi kantor. Berarti harus memakai /26 yang dimana memiliki 4 block subnet.

# Contoh Soal

## Topologi Pertama

```
Client-A ----- Switch-A ----- Router ----- Switch-B ----- Client-B
```

|No.| Nama Perangkat | Interface | Ip Address |
|---|---|---|---|
|1. | Router | Ether0 -> Switch-A | 172.16.0.1/27 |
|2. | Router | Ether1 -> Switch-B | 172.16.0.33/27 |
|3. | Switch-A | Ether1 -> Router | - |
|4. | Switch-A | Ether2 -> Client-A | - |
|5. | Switch-B | Ether1 -> Router | - |
|6. | Switch-B | Ether2 -> Client-B | - |
|7. | Client-A | Ether0 -> Switch-A | 172.16.0.2/27 |
|8. | Client-B | Ether0 -> Switch-B | 172.16.0.34/27 |

## Ketentuan

1. Client-A dapat melakukan ping ke Router
2. Client-A dan Client-B bisa saling ping

## Kunci Jawaban
```
Router>enable
Router#config terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Router(config)#interface fa0/0
Router(config-if)#ip address 172.16.0.1 255.255.255.224
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#interface fa0/1
Router(config-if)#ip address 172.16.0.33 255.255.255.224
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#do write
Building configuration...
[OK]
```
&nbsp;

## Topologi Kedua

```
[PC-1] ----- [Switch-1] ----- [Router-utama] ----- [Switch-2] ----- [PC-2]
                                     |
                                     |
                                   [PC-3]
```

|No.| Nama Perangkat | Interface | Ip Address |
|---|---|---|---|
|1. | Router-utama | Ether0 -> Switch-1 | 192.168.1.1/26 |
|2. | Router-utama | Ether1 -> Switch-2 | 192.168.1.65/26 |
|3. | Router-utama | Ether2 -> PC-3 | 192.168.1.129/26 |
|4. | Switch-1 | Ether1 -> Router-utama | - |
|5. | Switch-1 | Ether2 -> PC-1 | - |
|6. | Switch-2 | Ether1 -> Router-utama | - |
|7. | Switch-2 | Ether2 -> PC-1 | - |
|8. | PC-1 | Ether0 -> Switch-1 | 192.168.1.2/26
|9. | PC-2 | Ether0 -> Switch-2 | 192.168.1.66/26
|10. | PC-3 | Ether0 -> Router-utama | 192.168.1.130/26

## Ketentuan

1. Client dapat melakukan ping ke Router-utama
2. Dapat melakukan ping sesama Client

## Kunci Jawaban
```
Router>enable
Router#config terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Router(config)#int g0/0
Router(config-if)#ip address 192.168.1.1 255.255.255.192
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#int g0/1
Router(config-if)#ip address 192.168.1.65 255.255.255.192
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#int g0/2
Router(config-if)#ip address 192.168.1.129 255.255.255.192
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#do write
Building configuration...
[OK]
```
=======


# IP Address
Apa itu IP Address? Bayangin kamu tinggal di sebuah kota besar. Setiap rumah punya alamat unik supaya kurir tahu harus ke mana mengantarkan paket. Nah, IP Address adalah alamat rumah untuk setiap perangkat di jaringan.

| Nama kelas | IP Private | IP Publik | Penggunaan |
|---|---|---|---|
| Kelas A | 10.0.0.0 – 10.255.255.255 | 1.0.0.0 – 9.255.255.255 dan 11.0.0.0 – 127.255.255.255 *(kecuali IP loopback 127.0.0.1) |  Skala jaringan sangat besar (skala internasional atau perusahaan multinasional). |
| Kelas B | 172.16.0.0 – 172.31.255.255 | 128.0.0.0 – 172.15.255.255 dan 172.32.0.0 – 191.255.255.255 |  Skala jaringan menengah, seperti kampus atau perusahaan besar. |
| Kelas C | 192.168.0.0 – 192.168.255.255 | 192.0.0.0 – 192.167.255.255 dan 192.169.0.0 – 223.255.255.255 | Skala jaringan kecil, seperti warnet, kantor cabang, atau jaringan rumah. |

| Nama Kelas | Rentang IP | Penggunaan |
|----|----|----|
| Kelas D | 224.0.0.0 – 239.255.255.255 | Tidak dibagi menjadi publik/privat karena dikhususkan untuk transmisi multicast dalam jaringan. |
| Kelas E | 240.0.0.0 – 255.255.255.255 | Dicadangkan oleh IANA secara eksklusif untuk keperluan eksperimen, penelitian (Research and Development), dan masa depan. |

# Subnetting
Subnetting itu ibarat membagi komplek perumahan besar menjadi beberapa blok kecil. Tujuannya supaya jaringan lebih rapi, efisien, dan aman.
Contoh soal nyata seperti di dunia kerja:
Kamu dapat IP 192.168.10.0/24 dan diminta bagi menjadi 4 subnet untuk 4 divisi kantor. Berarti harus memakai /26 yang dimana memiliki 4 block subnet.

# Contoh Soal

## Topologi Pertama

```
Client-A ----- Switch-A ----- Router ----- Switch-B ----- Client-B
```

|No.| Nama Perangkat | Interface | Ip Address |
|---|---|---|---|
|1. | Router | Ether0 -> Switch-A | 172.16.0.1/27 |
|2. | Router | Ether1 -> Switch-B | 172.16.0.33/27 |
|3. | Switch-A | Ether1 -> Router | - |
|4. | Switch-A | Ether2 -> Client-A | - |
|5. | Switch-B | Ether1 -> Router | - |
|6. | Switch-B | Ether2 -> Client-B | - |
|7. | Client-A | Ether0 -> Switch-A | 172.16.0.2/27 |
|8. | Client-B | Ether0 -> Switch-B | 172.16.0.34/27 |

## Ketentuan

1. Client-A dapat melakukan ping ke Router
2. Client-A dan Client-B bisa saling ping

## Kunci Jawaban
```
Router>enable
Router#config terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Router(config)#interface fa0/0
Router(config-if)#ip address 172.16.0.1 255.255.255.224
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#interface fa0/1
Router(config-if)#ip address 172.16.0.33 255.255.255.224
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#do write
Building configuration...
[OK]
```
&nbsp;

## Topologi Kedua

```
[PC-1] ----- [Switch-1] ----- [Router-utama] ----- [Switch-2] ----- [PC-2]
                                     |
                                     |
                                   [PC-3]
```

|No.| Nama Perangkat | Interface | Ip Address |
|---|---|---|---|
|1. | Router-utama | Ether0 -> Switch-1 | 192.168.1.1/26 |
|2. | Router-utama | Ether1 -> Switch-2 | 192.168.1.65/26 |
|3. | Router-utama | Ether2 -> PC-3 | 192.168.1.129/26 |
|4. | Switch-1 | Ether1 -> Router-utama | - |
|5. | Switch-1 | Ether2 -> PC-1 | - |
|6. | Switch-2 | Ether1 -> Router-utama | - |
|7. | Switch-2 | Ether2 -> PC-1 | - |
|8. | PC-1 | Ether0 -> Switch-1 | 192.168.1.2/26
|9. | PC-2 | Ether0 -> Switch-2 | 192.168.1.66/26
|10. | PC-3 | Ether0 -> Router-utama | 192.168.1.130/26

## Ketentuan

1. Client dapat melakukan ping ke Router-utama
2. Dapat melakukan ping sesama Client

## Kunci Jawaban
```
Router>enable
Router#config terminal
Enter configuration commands, one per line.  End with CNTL/Z.
Router(config)#int g0/0
Router(config-if)#ip address 192.168.1.1 255.255.255.192
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#int g0/1
Router(config-if)#ip address 192.168.1.65 255.255.255.192
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#int g0/2
Router(config-if)#ip address 192.168.1.129 255.255.255.192
Router(config-if)#no shutdown
Router(config-if)#exit
Router(config)#do write
Building configuration...
[OK]
```
>>>>>>> 4124523f84676146044d6331f579546026685af4
