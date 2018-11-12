#!/bin/bash
# Make sure to execute only 1 time at each network bootstrap
# See https://superuser.com/questions/695482/script-in-if-up-d-appears-to-be-running-3-times-only-want-it-to-run-once

[ "$IFACE" = 'eth0' ] || exit 0

# Make sure the kernel forwards packets
sysctl net.ipv4.ip_forward=1


# Set-up the interfaces
ip link set dev eth1 up
ip link set dev eth2 up
ip addr add 10.0.1.33/30 dev eth1
ip addr add 10.0.1.38/30 dev eth2


