export DEBIAN_FRONTEND=noninteractive

echo "****************************************************"
echo "           Installing docker"
echo "****************************************************"

# Install docker and run nginx inside
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce --assume-yes --force-yes

# Create a sample index page
# Just to do an automatic testing, not a valid html page
mkdir -p /var/www
chmod +r /var/www
echo "Just a test page!" > /var/www/index.html

echo "****************************************************"
echo "           Installing nginx on docker"
echo "****************************************************"


# Run docker linking the  /var/www folder to the physical (well, still virtual :) ) machine
# link local 80 port to container's 80
# run in detached mode
docker run --name docker-nginx \
-p 80:80 -d \
-v /var/www:/usr/share/nginx/html:ro \
nginx

echo "****************************************************"
echo "           nginx reachable on port 80"
echo "****************************************************"
