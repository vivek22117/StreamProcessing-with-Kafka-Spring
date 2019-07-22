#!/usr/bin/env bash

echo 'after install script starting....'

mkdir /home/ec2-user/rsvp/logs
chmod +rw /home/ec2-user/rsvp/logs
touch /home/ec2-user/rsvp/logs/stdout.log
touch /home/ec2-user/rsvp/logs/stderr.log

chown -R ec2-user:ec2-user /home/ec2-user/rsvp

mv /home/ec2-user/rsvp/rsvp-*.jar /home/ec2-user/rsvp/lib/rsvp-collection-tier-kafka-kinesis-0.0.1-webapp.jar

