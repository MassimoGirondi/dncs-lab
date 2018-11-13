export DEBIAN_FRONTEND=noninteractive

echo "****************************************************"
echo "           Installing utilities"
echo "****************************************************"

apt-get update
apt-get install -y tcpdump curl traceroute --assume-yes

# Identify the config file and copy it to a good location
FILE=`ls *_boot.sh`
chmod +x $FILE
mv $FILE /usr/bin/$FILE

# Add to crontab if not exists (avoid multiple entries)
grep '/usr/bin/$FILE' /etc/crontab && echo -e "@reboot\troot\t/usr/bin/$FILE" >> /etc/crontab

# Execute now
echo "****************************************************"
echo "           Applying network settings"
echo "****************************************************"

/usr/bin/$FILE

echo "****************************************************"
echo "                      Done!"
echo "****************************************************"
