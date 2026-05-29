# 2026-05-29 11:40:04 by RouterOS 7.20.8
# software id = ZSSR-NRDP
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=vip-20Mbps ranges=10.10.10.10-10.10.10.254
add name=member-10Mbps ranges=10.10.20.10-10.10.20.254
/ppp profile
add dns-server=8.8.8.8 local-address=10.10.20.1 name=vip-20Mbps only-one=no \
    rate-limit=20M/20M remote-address=vip-20Mbps
add dns-server=8.8.8.8 local-address=10.10.10.1 name=Member-10Mbps only-one=\
    no rate-limit=10M/10M remote-address=member-10Mbps
/interface pppoe-server server
add default-profile=vip-20Mbps disabled=no interface=ether2 service-name=\
    kalisari
add default-profile=Member-10Mbps disabled=no interface=ether3 service-name=\
    pagilaran
/ip dhcp-client
add default-route-tables=main interface=ether1
/ip firewall filter
add action=accept chain=forward comment="Izinkan Koneksi Established" \
    connection-state=established,related
add action=accept chain=forward comment="Akses Internet Kalisari" \
    in-interface=<pppoe-yugaa> out-interface=ether1
add action=accept chain=forward comment="Akses Internet Pagilaran" \
    in-interface=<pppoe-arkan> out-interface=ether1
add action=drop chain=input comment="Blok Winbox dari Internet" dst-port=8291 \
    in-interface=ether1 protocol=tcp
add action=drop chain=forward comment="Isolasi Kalisari ke Pagilaran" \
    in-interface=<pppoe-yugaa> out-interface=<pppoe-arkan>
add action=drop chain=forward comment="Isolasi Pagilaran ke Kalisari" \
    in-interface=<pppoe-arkan> out-interface=<pppoe-yugaa>
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1
/ppp secret
add name=yugaa profile=vip-20Mbps service=pppoe
add name=arkan profile=Member-10Mbps service=pppoe
/system identity
set name="Lab MikroTik A"
