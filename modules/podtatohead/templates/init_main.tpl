#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
# sudo usermod -a -G docker ec2-user
sudo useradd podtato-user
sudo usermod -a -G docker podtato-user
sudo -u podtato-user docker run \
-p 8080:8080 \
-e PORT=8080 \
-e HATS_HOST=${hats_host} \
-e HATS_PORT=8080 \
-e ARMS_HOST=${arms_host} \
-e ARMS_PORT=8080 \
-e LEGS_HOST=${legs_host} \
-e LEGS_PORT=8080 \
-d ${container_image}:${podtato_version}

################################################Data Dog
sudo -u podtato-user docker run -d \
--name dd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true \
-e DD_API_KEY=${VarDdApiKey} \
-e DD_SITE="datadoghq.eu" ${VarDdImage}

################################################## OAUTH- packages
sudo amazon-linux-extras install epel -y
sudo yum-config-manager --enable epel
sudo yum install certbot -y
#export PUBLIC_IPV4_ADDRESS="$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"   #old

################################################## OAUTH- Prework Logging/Analyze
cd /opt
sudo mkdir log
cd log
sudo chmod 777 /opt/log/

################################################## OAUTH- Wait for elb IP
sleep 120
################################################## OAUTH- IP of the elb
export PUBLIC_IPV4_ADDRESS=$(ping -q -c1 -t1 ${PUBLIC_DNS_ADDRESS} | grep -Eo "([0-9]+\.+[0-9]+\.?){2}")
echo $PUBLIC_IPV4_ADDRESS > LogPublicIp.txt

################################################## OAUTH- Create certificates
sudo certbot certonly --standalone --preferred-challenges http -d $PUBLIC_IPV4_ADDRESS.nip.io --staging

mkdir -p /tmp/oauth2-proxy
sudo mkdir -p /opt/oauth2-proxy
cd /tmp/oauth2-proxy
################################################## OAUTH- Download & move OAUTH
curl -sfL https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.1.3/oauth2-proxy-v7.1.3.linux-amd64.tar.gz | tar -xzvf -
sudo mv oauth2-proxy-v7.1.3.linux-amd64/oauth2-proxy /opt/oauth2-proxy/

################################################## OAUTH- Build Shell Vars
export COOKIE_SECRET=$(python -c 'import os,base64; print(base64.urlsafe_b64encode(os.urandom(16)).decode())')

export GITHUB_USER=${gitHubUser}
export GITHUB_CLIENT_ID=${gitHubClientId}
export GITHUB_CLIENT_SECRET=${gitHubClientSecret}

export PUBLIC_URL=$PUBLIC_IPV4_ADDRESS.nip.io
export PUBLIC_FULL_URL=https://$PUBLIC_URL

cd /opt/log/
echo $PUBLIC_FULL_URL > LogPublicFullUrl.txt

sudo /opt/oauth2-proxy/oauth2-proxy \
--github-user=$GITHUB_USER  \
--cookie-secret=$COOKIE_SECRET \
--client-id=$GITHUB_CLIENT_ID \
--client-secret=$GITHUB_CLIENT_SECRET \
--email-domain="*" \
--upstream=http://127.0.0.1:8080 \
--provider github \
--cookie-secure false \
--redirect-url=https://$PUBLIC_URL/oauth2/callback \
--https-address=":443" \
--force-https \
--tls-cert-file=/etc/letsencrypt/live/$PUBLIC_URL/fullchain.pem \
--tls-key-file=/etc/letsencrypt/live/$PUBLIC_URL/privkey.pem > /opt/log/oauthLog.txt