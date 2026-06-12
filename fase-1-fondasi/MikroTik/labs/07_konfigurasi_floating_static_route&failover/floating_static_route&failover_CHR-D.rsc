# 2026-06-12 12:59:08 by RouterOS 7.20.8
# software id = 70E7-GDGV
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=10.10.30.2/24 interface=ether1 network=10.10.30.0
add address=10.10.40.2/24 interface=ether2 network=10.10.40.0
/ip route
add dst-address=10.10.10.0/24 gateway=10.10.30.1
add dst-address=10.10.20.0/24 gateway=10.10.40.1
/system identity
set name=CHR-D
