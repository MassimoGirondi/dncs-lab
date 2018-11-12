export DEBIAN_FRONTEND=noninteractive
apt-get install -y apt-transport-https ca-certificates curl software-properties-common --assume-yes --force-yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce --assume-yes --force-yes

mkdir -p /var/www
chmod +r /var/www

echo "Just a test page!" > /var/www/index.html

#Run docker linking the  /var/www folder to the physical machine
docker run --name nginx -p 80:80 -d nginx -v /var/www:/usr/share/nginx/html:ro
