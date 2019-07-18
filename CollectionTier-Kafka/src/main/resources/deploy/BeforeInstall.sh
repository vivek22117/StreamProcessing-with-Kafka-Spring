#!/usr/bin/env bash

echo 'before install script running...'

cd /home/ec2-user/rsvp
sudo find . -type f -regex '.*' -delete
