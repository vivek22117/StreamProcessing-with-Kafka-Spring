#!/usr/bin/env bash

echo "Install Java JDK 8"
yum remove -y java
yum install -y java-1.8.0-openjdk


cat << EOF >> /home/ec2-user/.bash_profile
DAEMON_PATH=/home/ec2-user/kafka/bin
export PATH=$PATH:$DAEMON_PATH
export KAFKA_HEAP_OPTS=-Xmx256M -Xms128M
EOF


cd /usr/local/bin/setup_kafka_bin
wget -P /home/ec2-user http://apache.mirror.digitalpacific.com.au/kafka/1.1.1/kafka_2.12-1.1.1.tgz
tar xf /home/ec2-user/kafka_2.12-1.1.1.tgz -C /home/ec2-user
ln -s /home/ec2-user/kafka_2.12-1.1.1 /home/ec2-user/kafka
chown -R ec2-user:ec2-user /home/ec2-user/kafka /home/ec2-user/kafka_2.12-1.1.1
rm /home/ec2-user/kafka_2.12-1.1.1.tgz

vi /etc/systemd/system/kafka.service
[Unit]
Description=Kafka
After=network.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
Environment=KAFKA_HEAP_OPTS=-Xmx256M -Xms128M
ExecStart=/home/ec2-user/kafka/bin/kafka-server-start.sh /home/ec2-user/kafka.properties
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target


vi /home/ec2-user/kafka.properties
broker.id=${broker_id}
advertised.listeners=PLAINTEXT://${kafka_private_ip}:9092
delete.topic.enable=true
log.dirs=/data/kafka
num.partitions=${num_partitions}
default.replication.factor=${repl_factor}
min.insync.replicas=${min_insync_replica}
log.retention.hours=${log_retention}
zookeeper.connect=${zookeeper_connect}
zookeeper.connection.timeout.ms=${zk_connection_timeout}
auto.create.topics.enable=${auto_topics}
offsets.topic.replication.factor=${offset_topic_repl}




systemctl enable kafka.service
systemctl start kafka.service


cd /usr/local/bin/setup_monitoring
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


