#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
#sudo usermod -a -G docker ec2-user
sudo useradd podtato-user
sudo usermod -a -G docker podtato-user
sudo -u podtato-user docker run \
-p 8080:8080 \
-e PORT=8080 \
-e LEFT_VERSION=${left_version} \
-e RIGHT_VERSION=${right_version} \
-d ${container_image}:${podtato_version}

sudo -u podtato-user docker run -d \
--name dd-agent \
-v /var/run/docker.sock:/var/run/docker.sock:ro \
-v /proc/:/host/proc/:ro \
-v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
-e DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true \
-e DD_API_KEY=${VarDdApiKey} \
-e DD_SITE="datadoghq.eu" ${VarDdImage}