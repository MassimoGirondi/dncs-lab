#!/bin/bash

# Make sure the kernel forwards packets
sysctl net.ipv4.ip_forward=1


# Set-up the interfaces
ip link set dev eth1 up
ip link set dev eth2 up
ip addr add 10.0.1.33/30 dev eth1
ip addr add 10.0.1.38/30 dev eth2


#Easy way: forward everything to the other router

ip route del default
ip route add default via 10.0.1.37
