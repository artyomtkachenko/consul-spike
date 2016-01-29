#!/bin/bash
echo "Cleaning up"
yum -y clean all

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]
    then
        sed -i '/^HWADDR/d' "$ndev"
        sed -i '/^UUID/d' "$ndev"
    fi
done
