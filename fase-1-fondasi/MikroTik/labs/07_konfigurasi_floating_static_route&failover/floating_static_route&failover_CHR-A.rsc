# 2026-06-12 12:53:44 by RouterOS 7.20.8
# software id = TT9V-II59
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=10.10.10.1/24 interface=ether1 network=10.10.10.0
add address=10.10.20.1/24 interface=ether2 network=10.10.20.0
/ip route
add check-gateway=ping distance=1 dst-address=10.10.30.0/24 gateway=\
    10.10.10.2
add check-gateway=ping distance=10 dst-address=10.10.30.0/24 gateway=\
    10.10.20.2
add check-gateway=ping distance=1 dst-address=10.10.40.0/24 gateway=\
    10.10.10.2
add check-gateway=ping distance=10 dst-address=10.10.40.0/24 gateway=\
    10.10.20.2
/system identity
set name=CHR-A
