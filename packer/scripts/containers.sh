#!/bin/bash
set -e
echo "Baking a Base container. We will use it later, when we do Vagrant provision"

yum install vim-minimal iputils iproute systemd-networkd systemd-resolved  systemd passwd -y --releasever=7  --nogpg --installroot="${MCTL_ROOT}/base"

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

#Consul binaries are installed by consul.sh
cp /usr/local/bin/consul "${MCTL_ROOT}/base/usr/local/bin/"
cp /usr/local/bin/consul-template "${MCTL_ROOT}/base//usr/local/bin/"

mkdir "${MCTL_ROOT}/base/etc/consul.d"
cat > "${MCTL_ROOT}/base/etc/consul.json" << EOF
{
  "datacenter": "test-lab1",
  "data_dir": "/tmp/consul",
  "log_level": "INFO",
  "bind_addr": "0.0.0.0"
}
EOF

cat > "${MCTL_ROOT}/base/etc/systemd/system/consul.service" << EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -join 10.0.2.15 -config-file /etc/consul.json -config-dir /etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF
systemd-nspawn -D "${MCTL_ROOT}/base" systemctl enable consul.service
sleep 5

#Start containers on a boot
systemctl enable machines.target
