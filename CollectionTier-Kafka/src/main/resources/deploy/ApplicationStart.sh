#!/usr/bin/env bash

echo 'application start script starting....'

cd /home/ec2-user/rsvp

DAEMON="java"
DAEMONOPTS="-jar -Dspring.profiles.active=$Environment rsvp-collection-tier-kafka-kinesis-0.0.1-webapp.jar"

JAVAOPTS=""
if [[ "$Environment" == "devl" ]]; then
  JAVAOPTS="-Xms512m -Xmx1024m"
elif [[ "$Environment" == "prod" ]]; then
  JAVAOPTS="-Xms1024m -Xmx2048m"
fi


sudo $DAEMON $JAVAOPTS $DAEMONOPTS > /dev/null 2> /dev/null < /dev/null &