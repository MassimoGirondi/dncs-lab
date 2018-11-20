# DNCS-LAB assignment

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.

## Table of contents

- [Netowrk map](#network-map)
- [IP subnetting](#ip-subnetting)
  * [Exact subnets tailoring](#exact-subnets-tailoring)
  * [Smallest big-enough subnets](#smallest-big-enough-subnets)
- [IP Addresses](#ip-addresses)
- [Virtual LANs](#virtual-lans)
- [IPs addresses and VLAN recap](#ips-addresses-and-vlan-recap)
- [Vagrant files structure](#vagrant-files-structure)
- [Routing](#routing)
  * [`router-1` routing table](#router-1-routing-table)
  * [`router-2` routing table](#router-2-routing-table)
- [Web server](#web-server)
- [How to test](#how-to-test)
  * [Reachability](#reachability)
  * [Router functionalities](#router-functionalities)
  * [Web server](#web-server-1)
  * [Switch](#switch)
  * [VLAN Separation](#vlan-separation)
  * [Routing tables](#routing-tables)
- [Requirements](#requirements)
- [How-to install](#how-to-install)
- [License](#license)



# Network map
Below there is a map of the network, with all the IP addresses specified.

```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |.37       .38|            |
        |     |                |            |10.0.1.36/30 |            |
        |  M  |                +------------+             +------------+
        |  A  |        10.0.0.1/24   |eth1.10                 .33|eth1
        |  N  |        10.0.1.1/27   |eth1.20        10.0.1.32/30|
        |  A  |                      |                        .34|eth1
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|       TRUNK       |           | host-2-c |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |  10           20  |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |10.0.0.2/24  |10.0.1.2/27         |
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
- **C**: The portion containing the `host-1-c` (plus a `router-2` IP).
- **D**: The link between the two routers.

Several approaches are possible to assign the IPs:

##  Exact subnets tailoring
To achieve the smallest loss of IP addresses we can use subnetting (and supernetting) to allocate only the IP  addresses that we need. In this case:
- **A**: 130 hosts + 1 router = 131 addresses -> We can use a /25 and a /29 subnets to obtain 132 IP addresses (with other 4 IP  addresses lost for network and broadcast addresses)
- **B**: 25 hosts + 1 router = 26 addresses -> We can use a /28 and two /29 subnets to obtain 26 IP addresses (with other 6 IP addresses lost for network and broadcast addresses)
- **C**: 1 host + 1 router = 2 addresses -> We need just a /30 network: 2 IPs (and the 2  addresses for network and broadcast addresses)
- **D**: 2 hosts (the routers) -> As above, a /30 network is fine.

However, splitting the network this way can be a little tricky when dealing with routing paths: we have to define very carefully the routing rules to get the correct behavior.

If we calculate the ratio between the available IP  addresses and all the IP addresses allocated we find that is pretty low: 132/136 + 26/32 + 2/4 + 2/4 = 70%.
If we compute the ratio of the total IP addresses used and all the ones available, we find that it's the best: 131/132 + 26/26 + 2/2 + 2/2 = 100%.

Another problem about this solution will come up when new hosts are connected to the network and new IP addresses need to be reserved: the network masks will need to be changed to accommodate these new hosts (even for only one). Similarly, the routing rules need to be modified.


## Smallest big-enough subnets
The simplest approach to get the smallest loss of IP addresses is to choose the smallest network classes that can accommodate all the hosts of that portion of the network.
- **A**: /24 network provides 254 addresses
- **B**: /27 network provides 30 addresses
- **C**: /30 network provides 2 addresses
- **D**: /30 network provides 2 addresses

With this configuration, we obtain a available/allocated IP ratio of 73% and a used/available IP ratio of 60%.

Even if it's not optimal (we have a lower utilization), it's the best one when dealing with real networks. Moreover, if we want to add some hosts in network A or B, this can be done as far as we don't saturate the network (123 more hosts on A and 4 more hosts on B) without changing routing rules or network masks.

# IP Addresses
So, after this brief discussion, I choose the second option, the simplest and the easiest to build and maintain. We can define the addresses used on the networks as below.

| Network |     Network Mask      | # needed IPs | # available IPs | Network address | First IP  | Last IP    |
|:-------:|:---------------------:|:------------:|:---------------:|:---------------:|:---------:|:----------:|
|   **A** |	/24 - 255.255.255.0   |      131     |       254       |    10.0.0.0     | 10.0.0.1  | 10.0.0.254 |
|   **B** | /27 - 255.255.255.224 |      26      |       30        |    10.0.1.0     | 10.0.1.1  | 10.0.1.30  |
|   **C** | /30 - 255.255.255.252 |      2       |       2         |    10.0.1.32    | 10.0.1.33 | 10.0.1.34  |
|   **D** | /30 - 255.255.255.252 |      2       |       2         |    10.0.1.36    | 10.0.1.37 | 10.0.1.38  |


When choosing the networks addresses, any valid class can be taken, there is no "hard" rule. However, the first classes of each block is usually chosen, leaving space for other networks.
Since there is no requirement about the addresses to be used, we can use private IP addresses. In this case, I chose networks in the 10.0.0.0/8 class, but the 172.16.0.0/12 or the 192.168.0.0/16 classes can be chosen as well.

The chosen IP classes above are one after the other, this is not a very nice approach when we plan to have upgrades in future: could be better to separate the networks a little more (e.g. put the network B on 10.1.0.0/26), so we can easily expand the networks without changing the addresses of the host already configured. However, this is not required by this assignment and we can keep them adjacent.

By common practice, the routers (default gateways) will have the first IP of each subnet.

# Virtual LANs

Even if it's not required, is better to map the IP subnets on different VLANs for the portion of network where we have networks **A** and **B**. The VLANs will follow the 802.1Q standard.
To connect the `router-1` to both LANs we can use either two different links on two access ports or a trunk link. I've chose the latter.

All the host in network **A** and **B** use access ports on the `switch`: the **B**'s host will never know to be on the same physical switch of network **A**'s hosts and viceversa.

All the other links can be configured as untagged (or with an arbitrary VLAN tag, even if there is no need, at the moment, to do it).

# IPs addresses and VLAN recap

| Network | VLAN ID |Network address|
|:-------:|:-------:|:-------------:|
|   **A** |   10    |  10.0.0.0/24  |
|   **B** |   20    |  10.0.1.0/27  |
|   **C** | No VLAN |  10.0.1.32/30 |
|   **D** | No VLAN |  10.0.1.36/30 |


|  Host    | Interface   | IP       | VLAN Tag |          Notes                        |
|:--------:|:-----------:|:--------:|:--------:|:-------------------------------------:|
|`router-1`| `eth1`      | --       |  --      | Splitted on subinterfaces (trunk link)|
|          | `eth1.10`   | 10.0.0.1 |    10    | Default Gateway for network A         |
|          | `eth1.20`   | 10.0.1.1 |    20    | Default Gateway for network B         |
|          | `eth2`      | 10.0.1.37| Untagged | Link to `router-2`                    |
|`router-2`| `eth2`      | 10.0.1.38| Untagged | Link to `router-1`                    |
|          | `eth1`      | 10.0.1.33| Untagged | Link to `host-2-c`                    |
|`host-1-a`| `eth1`      | 10.0.0.2 | Untagged | Access port on the switch, VLAN 10    |
|`host-1-b`| `eth1`      | 10.0.1.2 | Untagged | Access port on the switch, VLAN 20    |
|`host-2-c`| `eth1`      | 10.0.1.34| Untagged | Link to `router-2`                    |

Any other host on network **A** and **B** will get the next addresses on their respective networks.

All the `eth0` interfaces are configured by Vagrant (control interfaces) on the subnet `192.168.100.0/24`. I needed to change this to avoid routing problems: by default it's `10.0.0.0/8`.

Note that `switch` doesn't have any IP assigned to his interfaces (except for `eth0`): it works at level 2 and doesn't need them.


# Vagrant files structure

Every machine uses a file named `machine_name_boot.sh` as configuration script, carrying all the commands to be run at boot time.

Through the `common.sh` script, executed at provisioning time by each machine, the scripts above are copied to `/usr/bin` and add to crontab to be executed at reboot. It's not the best solution (systemd or other methods should be preferred); however, for testing purposes it's fine.

In the case of the routers, some other files are copied to configure the dynamic routing.


# Routing
Several ways can be used to define the routing tables. Static routing can be a easy and fast solution, however, for the purposes of the exercise and give more flexibility to the network, I decided to implement dynamic routing through OSPF. This is done with Quagga, a daemon that provides several routing protocols.

A static routing configuration is provided in the [`static-routing` branch](https://github.com/MassimoGirondi/dncs-lab/tree/dynamic_routing).

The configuration is the simplest possibile in both routers: they announce to each other the networks that they can reach. These configurations are contained in the files `router-1.ospfd.conf` and `router-2.ospf.conf`.


Below, there is a recap of the routing tables of the two routers, as it shoud be after the OSPF protocol has done its work.
## `router-1` routing table

| Destination    | Next-Hop        |
| :------------: | :-------------: |
| 10.0.0.1/24    | Direct delivery |
| 10.0.1.1/27    | Direct delivery |
| 10.0.1.36/30   | Direct delivery |
| 10.0.1.32/30   | 10.0.1.38       |

## `router-2` routing table

| Destination    | Next-Hop        |
| :------------: | :-------------: |
| 10.0.1.32/30   | Direct delivery |
| 10.0.1.36/30   | Direct delivery |
| 10.0.0.0/24    | 10.0.1.37       |
| 10.0.1.0/27    | 10.0.1.37       |

Other routes can be found in them, like the ones that announce the Vagrant management network. These can be ignored.

This configuration does not provide Internet access, which can be granted configuring a specific route on one of the two routers.

# Web server

To simplify the deployment of the web server running on `host-2-c`, a docker image of `ngnix` has been used.
The container is run in background and it's available through the port 80 of the host. The default index page has been replaced by a simple text to make the testing easier, even if it's not a valid html file.

# How to test

**TL;DR** The script `test.sh` runs almost all the tests needed automatically.

Please note that due to the dynamic routing, the hosts may not see each other immediately after routers boot. Give some minutes to OSPF to complete its job and everything will work.

## Reachability

To test the reachability between the networks, the following commands can be used:

|Host             |  Command                | Action                                                                         | Expected behavior                                                        |
| :-------------: | :----------------------:| :----------------------------------------------------------------------------: |  :---------------------------------:                                     |
| `host-1-a`      | `ping 10.0.1.1`         | Ping the `host-1-b` machine from `host-1-a`, test `router-1` routing           | Get the RTT time between the two hosts                                   |
| `host-1-a`      | `ping 10.0.1.34`        | Ping the `host-2-c` machine from `host-1-a`, test `router-1` and `router-2`    | Get the RTT time between the two hosts                                   |
| `host-2-c`      | `ping 10.0.0.1`         | Ping the `host-1-a` machine from `host-2-c`, test `router-1` and `router-2`    | Get the RTT time between the two hosts                                   |
| `host-1-b`      | `traceroute 10.0.0.1`   | Get the path between `host-1-b` and `host-1-a`                                 | Get the hops between the hosts: `10.0.1.1` and  `10.0.0.2`               |
| `host-1-a`      | `traceroute 10.0.1.34`  | Get the path between `host-1-a` and `host-2-c`                                 | Get the hops between the hosts: `10.0.0.1`, `10.0.1.38` and `10.0.1.34`  |

## Router functionalities
To check if the `router-1` is really doing its work between the networks **A** and **B**, the following command can be used:
```
sudo tcpdump -nni any icmp
```
When running one of the command above from any host, should provide the trace of the ICMP packets between the hosts.

The same can be done on `router-2`. Obviously, the `host-2-c` need to be one of the peers of the command in this case.

## Web server
To test if the web server on `host-2-c` is working, we just need to download the (sample) index page.

From any host, the following command can be used:

```
curl 10.0.1.34
```
If `Just a test page!` is shown in the terminal, the server is working correctly.

## Switch

To check the configuration of the switch is correct, you can use the command `sudo ovs-vsctl show` on it. The screen below should appear:

```
Bridge switch
    Port "eth1"
        Interface "eth1"
    Port switch
        Interface switch
            type: internal
    Port "eth2"
        tag: 10
        Interface "eth2"
    Port "eth3"
        tag: 20
        Interface "eth3"
ovs_version: "2.0.2"

```

It correctly shows that the `eth2` and  `eth3` ports are access ports (the traffic is tagged) whereas the `eth1` is a trunk port.

## VLAN Separation

To test that the packets of the two VLANs use two different interfaces on the `router-1`, the following command can be used:

```
sudo tcpdump -nni eth1.10 icmp
```

When running `ping 10.0.1.34` from `host-1-a` should show some packets traveling through the interface, whereas running the same command from `host-1-b` shouldn't show anything.

If the above is true, the switch is correctly split between the VLANs and the trunk link is well configured.

To check that the VLAN are separated on the L2 layer, the `arp` command can be used after some of the above commands has been executed.

If the VLANs work correctly, the arp tables, obrained with the `arp` command on the hosts, should show only the host and router. Otherwise, without the VLAN, also the other hosts could be there (e.g. the `host-1-a` in the arp table of `host-1-b`).

The arp table contains also the addresses of the Vagrant management interfaces but, as for the routing tables, we can ignore them.


## Routing tables

To check the routers' routing tables, the command below can be run on both routers:
```
ip router
```

The layout is not so user-friendly, the old `route` command can be used instead.

To check that the routes are set-up by OSPF, the command `vtysh -c "show ip route"` can be used: it shows all the routes of the current machine and their source: for the ones discovered by OSPF a `O` should appear at the beginning of the line.



# Requirements
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to install
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/MassimoGirondi/dncs-lab`
 - You should be able to launch the environment from within the cloned repo folder.

```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 6 VMs

```
[dncs-lab]$ vagrant status
machine states:

router-1                  running (virtualbox)
router-2                  running (virtualbox)
switch                    running (virtualbox)
host-1-a                  running (virtualbox)
host-1-b                  running (virtualbox)
host-2-c                  running (virtualbox)

```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh machine-name`
- To run some automatic tests you can use the `test.sh` script:
```
  bash test.sh
```



# License

The code published in this repository has been developed as an assignment for the course "Design of Network and Communication Systems", held at University of Trento.

The material in this repository is released under the GNU GPL v3 license.
This work is based on the material provided in https://github.com/dustnic/dncs-lab, which keeps all the rights on his material. See [LICENSE](LICENSE).
