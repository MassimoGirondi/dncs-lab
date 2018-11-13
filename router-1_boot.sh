#!/bin/bash

# Make sure the kernel forwards packets
sysctl net.ipv4.ip_forward=1


# Set-up the interfaces
ip link add link eth1 name eth1.10 type vlan id 10
ip link add link eth1 name eth1.20 type vlan id 20
ip link set dev eth1 up
ip link set dev eth2 up
ip link set dev eth1.10 up
ip link set dev eth1.20 up

ip addr add 10.0.0.1/24 dev eth1.10
ip addr add 10.0.1.1/27 dev eth1.20
ip addr add 10.0.1.37/30 dev eth2

#Routing rules
ip route del default
ip route add 10.0.1.32/30 via 10.0.1.38

# Uncomment to allow internet access
# ip route add default via 192.168.100.2
