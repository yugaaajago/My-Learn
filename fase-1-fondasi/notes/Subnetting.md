# Subnetting

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
