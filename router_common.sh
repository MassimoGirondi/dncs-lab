#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "****************************************************"
echo "           Installing utilities"
echo "****************************************************"

apt-get update
apt-get install -y tcpdump curl traceroute quagga --assume-yes

# Identify the config file and copy it to a good location
FILE=`ls *_boot.sh`
chmod +x $FILE
mv $FILE /usr/bin/$FILE

# Apply routing settings
mv *.ospfd.conf /etc/quagga/ospfd.conf
cp /usr/share/doc/quagga/examples/zebra.conf.sample /etc/quagga/zebra.conf
chown quagga:quagga /etc/quagga/{zebra,ospfd}.conf
chmod 640  /etc/quagga/{zebra,ospfd}.conf

# Add to crontab if not exists (avoid multiple entries)
#grep '/usr/bin/$FILE' /etc/crontab && echo -e "@reboot\troot\t/usr/bin/$FILE" >> /etc/crontab

echo -e "@reboot\troot\t/usr/bin/$FILE" >> /etc/crontab

# Enable daemon in quagga
sed -i s'/ospfd=no/ospfd=yes/' /etc/quagga/daemons
sed -i s'/zebra=no/zebra=yes/' /etc/quagga/daemons

# Execute now
echo "****************************************************"
echo "           Applying network settings"
echo "****************************************************"

/usr/bin/$FILE
service quagga restart

echo "****************************************************"
echo "                      Done!"
echo "****************************************************"
