#!/usr/bin/env bash

sudo systemctl stop kafka
mkdir -p /home/ec2-user/prometheus
wget -N -P /home/ec2-user/prometheus https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.3.1/jmx_prometheus_javaagent-0.3.1.jar
wget -N -P /home/ec2-user/prometheus https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/kafka-0-8-2.yml
mkdir -p /home/ec2-user/jolokia
wget -N http://search.maven.org/remotecontent?filepath=org/jolokia/jolokia-jvm/1.6.0/jolokia-jvm-1.6.0-agent.jar -O /home/ec2-user/jolokia/jolokia-agent.jar

if ! grep -q KAFKA_OPTS "/etc/systemd/system/kafka.service"; then
    sudo sed -i '/Environment="KAFKA_HEAP_OPTS/a Environment="KAFKA_OPTS=-javaagent:/home/ec2-user/prometheus/jmx_prometheus_javaagent-0.3.1.jar=8080:/home/ec2-user/prometheus/kafka-0-8-2.yml -javaagent:/home/ec2-user/jolokia/jolokia-agent.jar=host=*"' /etc/systemd/system/kafka.service
else
    sudo sed -i 's|Environment="KAFKA_OPTS.*|Environment="KAFKA_OPTS=-javaagent:/home/ec2-user/prometheus/jmx_prometheus_javaagent-0.3.1.jar=8080:/home/ec2-user/prometheus/kafka-0-8-2.yml -javaagent:/home/ec2-user/jolokia/jolokia-agent.jar=host=*"|g' /etc/systemd/system/kafka.service
fi
sudo systemctl daemon-reload
sudo systemctl start kafka