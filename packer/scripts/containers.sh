#!/bin/bash
set -e

MCTL_ROOT=/var/lib/machines
echo "Baking a Base container, we will use it later when we do Vagrant provision"

yum install vim-minimal iputils haproxy iproute systemd-networkd systemd-resolved  systemd passwd yum -y --releasever=7  --nogpg --installroot="${MCTL_ROOT}/base"

echo "Configuring network"
mkdir -p "${MCTL_ROOT}/base/etc/systemd/network"

cat > "${MCTL_ROOT}/base/etc/systemd/network/80-container-host0.network" << EOF
[Match]
Virtualization=container
Name=host0*

[Network]
DHCP=yes
LinkLocalAddressing=yes

[DHCP]
UseTimezone=yes
EOF

#Required for machinectl login base
echo "pts/0" >> "${MCTL_ROOT}/base/etc/securetty"

echo "Configuring systemd-resolved"
systemd-nspawn -D "${MCTL_ROOT}/base" rm -f /etc/resolv.conf

sleep 5
systemd-nspawn -D "${MCTL_ROOT}/base" ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

#We want resolve containers by a name
cat > "${MCTL_ROOT}/base/etc/nsswitch.conf" <<EOF 
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

echo "Making root user paswwordless"
sed -i --regexp-extended  's/^root.+/root::16831:0:99999:7:::/' "${MCTL_ROOT}/base/etc/shadow"

echo "Installing Consul tools"

curl -sk https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip -o /root/consul.zip
unzip /root/consul.zip -d /usr/local/bin

curl -sk https://releases.hashicorp.com/consul-template/0.12.2/consul-template_0.12.2_linux_amd64.zip -o /root/consul-template.zip
unzip /root/consul-template.zip -d /usr/local/bin

chmod 755 /usr/local/bin/consul
chmod 755 /usr/local/bin/consul-template

cp /usr/local/bin/consul "${MCTL_ROOT}/base//usr/local/bin/"
cp /usr/local/bin/consul-template "${MCTL_ROOT}/base//usr/local/bin/"

#Start containers on a boot
systemctl enable machines.target
