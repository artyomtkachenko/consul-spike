# Install critical packages if they are not installed
yum -y install dkms binutils gcc  gcc-c++ make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
#rm -f  /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso
