# 2026-05-30 11:39:54 by RouterOS 7.20.8
# software id = TT9V-II59
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=192.168.20.2-192.168.20.254
/ip address
add address=192.168.226.57/24 interface=ether1 network=192.168.226.0
add address=192.168.10.1/24 interface=ether2 network=192.168.10.0
add address=192.168.20.1/24 interface=ether3 network=192.168.20.0
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether3 name=dhcp1
/ip dhcp-server network
add address=192.168.20.0/24 gateway=192.168.20.1
/ip dns
set allow-remote-requests=yes servers=192.168.1.226,8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/ip route
add disabled=no dst-address=0.0.0.0/0 gateway=192.168.226.1 routing-table=\
    main suppress-hw-offload=no
/system identity
set name=CHR-A
