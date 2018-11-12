#!/bin/sh
ovs-vsctl add-br switch

# The access ports
ovs-vsctl add-port switch eth2 tag=10
ovs-vsctl add-port switch eth3 tag=20

# And the trunk link 
ovs-vsctl add-port switch eth1
