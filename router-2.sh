export DEBIAN_FRONTEND=noninteractive
# Install some utilities
apt-get update
apt-get install -y tcpdump curl --assume-yes --force-yes

# Make sure the commands are executed everytime the network is restarted
mv router-2_boot.sh /etc/network/if-up.d/
chmod +x /etc/network/if-up.d/router-2_boot.sh


# Run the script now (no need to reboot)
/etc/network/if-up.d/router-2_boot.sh

