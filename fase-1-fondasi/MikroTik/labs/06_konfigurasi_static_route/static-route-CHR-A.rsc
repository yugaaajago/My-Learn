# 2026-06-11 14:34:00 by RouterOS 7.20.8
# software id = TT9V-II59
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=192.168.10.1/24 interface=ether1 network=192.168.10.0
/ip route
add dst-address=192.168.20.0/24 gateway=192.168.10.2
/system identity
set name=CHR-A
