#!/usr/bin/env bash

echo "Install java8"
sudo yum remove -y java
sudo yum install -y java-1.8.0-openjdk


sudo yum -y update
sudo yum -y install awscli ruby
wget -O /tmp/install-codedeploy-agent https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
chmod +x /tmp/install-codedeploy-agent
sudo /tmp/install-codedeploy-agent auto
rm /tmp/install-codedeploy-agent

sudo service codedeploy-agent start