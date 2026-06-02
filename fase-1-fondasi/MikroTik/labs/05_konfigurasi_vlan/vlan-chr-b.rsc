# 2026-06-02 09:50:16 by RouterOS 7.20.8
# software id = 4E7A-DH52
#
/interface bridge
add name=bridge1 vlan-filtering=yes
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
/interface vlan
add interface=ether1 name=vlan10 vlan-id=10
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/interface bridge port
add bridge=bridge1 interface=ether1
add bridge=bridge1 interface=ether2 pvid=10
/interface bridge vlan
add bridge=bridge1 tagged=ether1 untagged=ether2 vlan-ids=10
add bridge=bridge1 tagged=ether1 vlan-ids=20
/ip address
add address=192.168.10.2/24 interface=vlan10 network=192.168.10.0
/ip route
add gateway=192.168.10.1
/system identity
set name=CHR-B
