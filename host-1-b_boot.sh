#!/bin/bash

ip link set dev eth1 up
ip addr add 10.0.1.2/27 dev eth1
ip route del default
ip route add default via 10.0.1.1
