# 2026-06-02 14:23:05 by RouterOS 7.20.8
# software id = 4E7A-DH52
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-batang user=yugaa
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip route
add gateway=pppoe-batang
/system identity
set name=CHR-B
