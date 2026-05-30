# 2026-05-30 11:41:42 by RouterOS 7.20.8
# software id = 4E7A-DH52
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=192.168.10.2/24 interface=ether1 network=192.168.10.0
add address=192.168.100.1/24 interface=ether2 network=192.168.100.0
/ip route
add dst-address=0.0.0.0/0 gateway=192.168.10.1
/system identity
set name=CHR-B
