# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "centos72-consul-new.box"
  config.vm.box_url = 'file:///Users/tim/work/git/personal/consul-spike/packer/builds/centos72-consul-new.box'
  #config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.network "forwarded_port", guest: 8040, host: 8040

  config.ssh.password = 'vagrant'
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = "2"
  end
end
