# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
    vb.customize ["modifyvm", :id, "--nicpromisc5", "allow-all"]
    # Change the management network address to not give problems to routing
    # Usually it's 10.0.0.0/8
    vb.customize ["modifyvm", :id, "--natnet1", "192.168.100/24"]
    vb.memory = 256
    vb.cpus = 1
  end
  config.vm.define "router-1" do |router1|
    router1.vm.box = "minimal/trusty64"
    router1.vm.hostname = "router-1"
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    router1.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router1.vm.provision "file", source: "router-1_boot.sh", destination: "router-1_boot.sh"
    router1.vm.provision "file", source: "router-1.ospfd.conf", destination: "router-1.ospfd.conf"
    router1.vm.provision "shell", path: "router_common.sh"
    #router1.vm.provision "shell", path: "common.sh"
    end
  config.vm.define "router-2" do |router2|
    router2.vm.box = "minimal/trusty64"
    router2.vm.hostname = "router-2"
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    router2.vm.network "private_network", virtualbox__intnet: "broadcast_router-inter", auto_config: false
    router2.vm.provision "file", source: "router-2_boot.sh", destination: "router-2_boot.sh"
    #router2.vm.provision "shell", path: "common.sh"
    router2.vm.provision "file", source: "router-2.ospfd.conf", destination: "router-2.ospfd.conf"
    router2.vm.provision "shell", path: "router_common.sh"
    end
  config.vm.define "switch" do |switch|
    switch.vm.box = "minimal/trusty64"
    switch.vm.hostname = "switch"
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-1", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    switch.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
    switch.vm.provision "file", source: "switch_boot.sh", destination: "switch_boot.sh"
    switch.vm.provision "shell", path: "switch.sh"

  end
  config.vm.define "host-1-a" do |hosta|
    hosta.vm.box = "minimal/trusty64"
    hosta.vm.hostname = "host-1-a"
    hosta.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    hosta.vm.provision "file", source: "host-1-a_boot.sh", destination: "host-1-a_boot.sh"
    hosta.vm.provision "shell", path: "common.sh"
  end
  config.vm.define "host-1-b" do |hostb|
    hostb.vm.box = "minimal/trusty64"
    hostb.vm.hostname = "host-1-b"
    hostb.vm.network "private_network", virtualbox__intnet: "broadcast_host_b", auto_config: false
    hostb.vm.provision "file", source: "host-1-b_boot.sh", destination: "host-1-b_boot.sh"
    hostb.vm.provision "shell", path: "common.sh"
  end
  config.vm.define "host-2-c" do |hostc|
    hostc.vm.box = "minimal/trusty64"
    hostc.vm.hostname = "host-2-c"
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_router-south-2", auto_config: false
    hostc.vm.network "private_network", virtualbox__intnet: "broadcast_host_a", auto_config: false
    hostc.vm.provision "file", source: "host-2-c_boot.sh", destination: "host-2-c_boot.sh"
    hostc.vm.provision "shell", path: "host-2-c.sh"
    hostc.vm.provision "shell", path: "common.sh"
  end
end
