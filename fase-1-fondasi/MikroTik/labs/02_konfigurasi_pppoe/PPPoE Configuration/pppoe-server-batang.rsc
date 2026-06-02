# 2026-06-02 13:28:06 by RouterOS 7.20.8
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
add name=vip-20Mbps ranges=10.10.10.10-10.10.10.254
add name=member-10Mbps ranges=10.10.10.254-10.10.20.10
/ppp profile
set *0 dns-server=8.8.8.8
add dns-server=8.8.8.8 local-address=10.10.10.1 name=vip-20Mbps rate-limit=\
    20M/20M remote-address=vip-20Mbps
add dns-server=8.8.8.8 local-address=10.10.20.1 name=member-10Mbps \
    rate-limit=10M/10M remote-address=member-10Mbps
/interface pppoe-server server
add default-profile=vip-20Mbps disabled=no interface=ether2 service-name=\
    kalisari
add default-profile=member-10Mbps disabled=no interface=ether3 service-name=\
    pagilaran
/ip dhcp-client
add interface=ether1
/ip dns
set allow-remote-requests=yes servers=192.168.226.1,8.8.8.8
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/ppp secret
add name=yugaa profile=vip-20Mbps
add name=arkan profile=member-10Mbps
/system identity
set name=CHR-A
/tool bandwidth-server
set authenticate=no
