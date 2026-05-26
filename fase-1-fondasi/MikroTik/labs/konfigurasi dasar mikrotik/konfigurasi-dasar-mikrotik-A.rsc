# 2026-05-26 12:20:00 by RouterOS 7.20.8
# software id = ZSSR-NRDP
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip address
add address=10.0.0.1/24 interface=ether2 network=10.0.0.0
/ip dhcp-client
add default-route-tables=main interface=ether1
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/system identity
set name="Lab MikroTik A"
