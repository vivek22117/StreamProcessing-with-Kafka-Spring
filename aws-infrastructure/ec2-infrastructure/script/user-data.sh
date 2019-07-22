#!/usr/bin/env bash

sudo yum update
sudo yum install aws-cli
cd /home/ec2-user
aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
chmod +x ./install
sudo ./install auto
