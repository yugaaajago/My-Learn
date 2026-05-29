# 2026-05-28 10:51:49 by RouterOS 7.20.8
# software id = H7PS-AHDD
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
/interface pppoe-client
add disabled=no interface=ether1 name=ppoe-pusat-smg user=yugaa
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=192.168.100.11-192.168.100.254
/ip address
add address=192.168.100.1/24 interface=ether2 network=192.168.100.0
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether2 name=dhcp1
/ip dhcp-server network
add address=192.168.100.0/24 dns-server=10.0.0.1 gateway=192.168.100.1
/ip route
add dst-address=0.0.0.0/0 gateway=ppoe-pusat-smg
/system identity
set name="Lab MikroTik B"
