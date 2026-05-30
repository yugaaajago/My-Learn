# 2026-05-30 11:42:15 by RouterOS 7.20.8
# software id = P790-A2P9
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=192.168.200.1/24 interface=ether2 network=192.168.200.0
/ip dhcp-client
add interface=ether1
/system identity
set name=CHR-C
