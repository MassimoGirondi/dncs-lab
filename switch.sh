export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y tcpdump --assume-yes
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common

#Make sure the commands are executed everytime the network is restarted
mv switch_boot.sh /etc/network/if-up.d/
chmod +x /etc/network/if-up.d/switch_boot.sh
/etc/network/if-up.d/switch_boot.sh

