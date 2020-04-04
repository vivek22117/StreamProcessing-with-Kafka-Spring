#!/bin/bash -xe

echo "Install java8"
yum update -y
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk


sudo yum -y update
sudo yum -y install awscli ruby
wget -O /tmp/install-codedeploy-agent https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x /tmp/install-codedeploy-agent
sudo /tmp/install-codedeploy-agent auto
rm /tmp/install-codedeploy-agent

sudo service codedeploy-agent start

echo "export Environment=${environment}" >> /etc/environment
echo "export LOG_DIR=/opt/dsr/logs/" >> /etc/environment

sudo aws deploy create-deployment --application-name ${rsvp_app_name} \
	--s3-location bucket="${rsvp_deploy_bucket}",key="${rsvp_app_key}",bundleType=zip \
	--deployment-group-name ${rsvp_group_name} --region ${aws_region}