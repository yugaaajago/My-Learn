# 2026-05-28 10:49:49 by RouterOS 7.20.8
# software id = 6XIE-31E2
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-pusat-smg user=arkan
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip route
add dst-address=0.0.0.0/0 gateway=pppoe-pusat-smg
/system identity
set name="Lab MikroTik C"
