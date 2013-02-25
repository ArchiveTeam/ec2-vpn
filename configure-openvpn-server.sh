#!/bin/sh
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.d/nat.conf
sysctl net.ipv4.ip_forward=1
cat <<EOF >> /etc/sysconfig/iptables
*filter
-A FORWARDING -i tan+ -j ACCEPT
COMMIT
*nat
:POSTROUTING ACCEPT [0:0]
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -s 192.168.2.0/24 -d 0.0.0.0/0 -o eth0 -j MASQUERADE
COMMIT
EOF
systemctl restart iptables.service
openvpn --genkey --secret /etc/openvpn/openvpn-key.txt
cat <<EOF > /etc/openvpn/openvpn.conf
port 1194
proto udp
dev tun
secret openvpn-key.txt
ifconfig 172.24.2.1 192.24.2.2
keepalive 10 120
comp-lzo
persist-key
persist-tun
status server-tcp.log
verb 3
EOF
systemctl enable openvpn\@openvpn.service
systemctl start openvpn\@openvpn.service
