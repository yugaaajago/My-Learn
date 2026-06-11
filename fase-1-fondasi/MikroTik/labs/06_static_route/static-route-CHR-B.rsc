# 2026-06-11 14:35:04 by RouterOS 7.20.8
# software id = 4E7A-DH52
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=192.168.10.2/24 interface=ether2 network=192.168.10.0
add address=192.168.20.1/24 interface=ether3 network=192.168.20.0
/ip dhcp-client
add add-default-route=no interface=ether1 use-peer-dns=no use-peer-ntp=no
/ip route
add
add gateway=192.168.226.1
/system identity
set name=CHR-B
