# 2026-05-26 13:24:56 by RouterOS 7.20.8
# software id = ZSSR-NRDP
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=pool-client ranges=10.10.10.10-10.10.10.50
/ppp profile
add dns-server=8.8.8.8 local-address=10.10.10.1 name=profile-lab rate-limit=\
    5M/5M remote-address=pool-client
/interface pppoe-server server
add default-profile=profile-lab disabled=no interface=ether2 service-name=\
    lab-isp
/ip address
add address=10.0.0.1/24 interface=ether2 network=10.0.0.0
/ip dhcp-client
add default-route-tables=main interface=ether1
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/ppp secret
add name=yugaa profile=profile-lab service=pppoe
/system identity
set name="Lab MikroTik A"
