# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |eth1
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           | host-2-c |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+ host-1-a |     | host-1-b |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# IP subnetting
We can split the network into 4 main areas:
- **A**: The portion containing the `host-1-a`and its siblings (plus a `router-1` IP)
- **B**: The portion containing the `host-1-b` and its siblings (plus a `router-1` IP)
- **C**: The portion containing the `host-1-c` (plus a `router-2` IP). We can consider this area as the servers area.
- **D**: The link between the two routers.

Several approaches are possible to assign the IPs:

##  Exact subnets tailoring
To achieve the smallest loss of IP addresses we can use subnetting (and supernetting) to allocate only the IPs that we need. In this case:
- **A**: 130 hosts + 1 router = 131 addresses -> We can use a /25 and a /29 subnets to obtain 132 IPs (with other 4 IP lost for network and broadcast addresses)
- **B**: 25 hosts + 1 router = 26 addresses -> We can use a /28 and two /29 subnets to obtain 26 IPs (with other 6 IP lost for network and broadcast addresses)
- **C**: 1 host + 1 router = 2 addresses -> We need just a /30 network: 2 IPs (and the 2 for network and broadcast addresses)
- **D**: 2 hosts (the routers) -> As above, a /30 network is fine.

However, splitting the network this way can be a little tricky when dealing with routing paths: we have to define very carefully the routing rules to get the correct behaviour.

If we calculate the ratio between the available IPs and all the IPs allocated we find that is pretty low: 132/136 + 26/32 + 2/4 + 2/4 = 70%.
If we compute the ratio of the total IPs used and all the ones available, we find that it's the best: 131/132 + 26/26 + 2/2 + 2/2 = 100%. 

Another problem about this solution will come up when new hosts are connected to the network and new IPs need to be reserved: the network masks will need to be changed to accommodate these new hosts (even for only one). Similarly, also the routing rules need to be modified.


## Smallest big-enough subnets
The simplest approach to get the smallest loss of IPs is to choose the smallest network classes that can accommodate all the hosts of that portion of the network.
- **A**: /24 network provides 254 addresses
- **B**: /27 network provides 30 addresses
- **C**: /30 network provides 2 addresses
- **D**: /30 network provides 2 addresses

With this configuration, we obtain a available/allocated IP ratio of 73% and a used/available IP ratio of 60%.

Even if it's not optimal (we have a lower utilization), it's the best one when dealing with real networks. Moreover, if we want to add some hosts in network A or B, this can be done as far as we don't saturate the network (123 hosts on A and 4 hosts on B) without changing routing rules or network masks.

# IP Addresses
So, after this brief discussion, I choose the second option, the simplest and the easiest to build and maintain. We can define the addresses used on the network.

| Network |     Network Mask      | # needed IPs | # available IPs | Network address | First IP  | Last IP    |
|:-------:|:---------------------:|:------------:|:---------------:|:---------------:|:---------:|:----------:|
|    A    |	/24 - 255.255.255.0   |      131     |       254       |    10.0.0.0     | 10.0.0.1  | 10.0.0.254 |
|    B    | /27 - 255.255.255.224 |      26      |       30        |    10.0.1.0     | 10.0.1.1  | 10.0.1.30  |
|    C    | /30 - 255.255.255.252 |      2       |       2         |    10.0.1.32    | 10.0.1.33 | 10.0.1.34  |
|    D    | /30 - 255.255.255.252 |      2       |       2         |    10.0.1.36    | 10.0.1.37 | 10.0.1.38  |


When choosing the networks addresses, any valid class can be taken, there is no "hard" rule. However, the first classes of each block is usually chosen, leaving space for other networks.
When there is no requirement about the addresses to be used, we can use private IPs, that avoid to buy public addresses. In this case, I chose the 10.0.0.0/8 class, but the 172.16.0.0/12 or the 192.168.0.0/16 can be chosen as well.

The chosen IP classes above are one after the other, allowing an easy configuration of any other ruoter outside the network: the longest-prefix trick can be used to route them (if there are no other 10.0.1.0 IPs to be routed, the 10.0.1.0/23 route will match all of these addresses).

This is not a very nice approach when we plan to have upgrades in future: could be better to separate the networks a little more (e.g. put the network B on 10.1.0.0/26), so we can easily expand the networks without changing the addresses of the host already configured. However, this is not required by this assignment and we can keep them adjacent.

By common practice, the routers (default gateways) will have the first IP of each subnet.

# Virtual LAN

Even if it's not required, is better to map the IP subnets on different VLAN for the portion of network where we have networks A and B. The VLAN will follow the 802.1Q standard.
To connect the `router-1` to both LANs we can use either two different links on two access ports or a trunk link. I've chose the latter.

All the host in network A and B use access ports on the `switch`: they'll never know to be on the same physical switch of network A's hosts.

All the other links can be configured as untagged (or with an arbitrary VLAN tag, even if there is no need, at the moment, to do it).

# Recap

| Network | VLAN ID |Network address|
|:-------:|:-------:|:-------------:|
|    A    |   10    |  10.0.0.0/24  |
|    B    |   20    |  10.0.1.0/27  |
|    C    | No VLAN |  10.0.1.32/30 |
|    D    | No VLAN |  10.0.1.36/30 |



|  Host    | Interface   | IP       | VLAN Tag |          Notes                        |
|:--------:|:-----------:|:--------:|:--------:|:-------------------------------------:|
|`router-1`| `eth1`      | --       |  --      | Splitted on subinterfaces (trunk link)|
|          | `eth1.10`   | 10.0.0.1 |    10    | Default Gateway for network A         |
|          | `eth1.20`   | 10.0.1.1 |    20    | Default Gateway for network B         |
|          | `eth2`      | 10.0.1.37| Untagged | Link to `router-2`                    |
|`router-2`| `eth2`      | 10.0.1.38| Untagged | Link to `router-1`                    |
|          | `eth1`      | 10.0.1.33| Untagged | Link to `host-2-c`                    |
|`host-2-c`| `eth1`      | 10.0.1.34| Untagged | Link to `router-2`                    |
|`host-1-a`| `eth1`      | 10.0.0.2 | Untagged | Access port on the switch VLAN 10     |
|`host-1-b`| `eth1`      | 10.0.1.2 | Untagged | Access port on the switch VLAN 20     |

Any other host on network A and B will get the next addresses on their respective networks.

All the `eth0` interfaces are configured by Vagrant (control interfaces).


# Vagrant files structure

Every machine uses a file named `machine_name.sh` as configuration script, carrying all the commands to be run at provisioning time. 

The routers and the switch have some commands to be run at boot. These are contained in the files `machine_name_boot.sh`, copied by Vagrant inside the machines. These are then copied into the `/etc/network/if-up.d/` folder, that contains scripts to be executed after a network card is powered up. Thanks to this, if the network service is restarted, the scripts will be executed again, configuring the interfaces.

The machines `host-1-a` and `host-1-b`, instead, requires only a generic script to install some utilities and the configuration of their IPs. The latter is done inside the Vagrant file, while the installation of the utilities is contained in the `common.sh` file.






# Requirements
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/dustnic/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
