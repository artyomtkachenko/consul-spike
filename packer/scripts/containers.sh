#!/bin/bash

set -e

MCTL_ROOT=/var/lib/machines
yum install systemd-networkd systemd-resolved  systemd passwd yum -y --releasever=7  --nogpg --installroot="${MCTL_ROOT}/base"
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

echo "pts/0" >> "${MCTL_ROOT}/base/etc/securetty"

systemctl enable machines.target

