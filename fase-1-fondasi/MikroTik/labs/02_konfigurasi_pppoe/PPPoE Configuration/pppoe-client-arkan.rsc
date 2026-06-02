# 2026-06-02 14:18:59 by RouterOS 7.20.8
# software id = P790-A2P9
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-batang user=arkan
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip route
add gateway=pppoe-batang
/system identity
set name=CHR-C
