#!/bin/sh
cat <<EOF > /etc/openvpn/openvpn.conf
dev tun
proto udp
remote $1 1194
resolv-retry infinite
nobind
secret openvpn-key.txt
ifconfig 172.24.2.2 172.24.2.1
comp-lzo
verb 3
dhcp-option DNS 8.8.8.8
redirect-gateway def1
EOF
systemctl enable openvpn\@openvpn.service
systemctl start openvpn\@openvpn.service
