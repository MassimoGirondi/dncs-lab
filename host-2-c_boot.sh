#!/bin/bash
ip link set dev eth1 up
ip addr add 10.0.1.34/30 dev eth1
ip route del default
ip route add default via 10.0.1.33
