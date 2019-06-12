#!/usr/bin/env bash

# Script to mount volume
while [[ ! -e /dev/xvdf ]] ; do echo "Waiting for attachment"; sleep 1 ; done

if [[ "$(file -b -s /dev/xvdf)" == "data" ]]; then
  mkfs.xfs -f /dev/xvdf
fi

mkdir -p /data/kafka
mount -t xfs /dev/xvdf /data/kafka
chown -R ec2-user:ec2-user /data/kafka
echo '/dev/xvdf /data/kafka xfs defaults 0 0' >> /etc/fstab