#!/bin/bash

set -e

yum install systemd-networkd systemd-resolved -y
mkdir -p /etc/systemd/network

systemctl disable network
systemctl disable NetworkManager
systemctl enable systemd-networkd
systemctl enable systemd-resolved

cat > /etc/systemd/network/br0.link <<EOF
[Match]
Type=bridge
[Link]
MACAddress=10:bf:48:d7:68:e1
EOF

cat > /etc/systemd/network/br0.netdev <<EOF
[NetDev]
Name=br0
Kind=bridge
EOF

cat > /etc/systemd/network/br0.network <<EOF
[Match]
Name=br0

[Network]
DHCP=yes
IPForward=yes
EOF

cat > /etc/systemd/network/20-dhcp.network <<EOF
[Match]
Name=enp*

[Network]
Bridge=br0
IPForward=yes
EOF

cat > /etc/systemd/network/80-containers.network <<EOF
[Match]
Name=ve-*

[Network]
Bridge=br0
EOF

#We want resolve containers by a name
cat > /etc/nsswitch.conf <<EOF 
passwd:     files sss mymachines
shadow:     files sss
group:      files sss mymachines

#sequence does metter
hosts:      files resolve mymachines myhostname

bootparams: nisplus [NOTFOUND=return] files

ethers:     files
netmasks:   files
networks:   files
protocols:  files
rpc:        files
services:   files sss

netgroup:   files sss

publickey:  nisplus

automount:  files
aliases:    files nisplus
EOF

rm -f /etc/resolv.conf
ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
