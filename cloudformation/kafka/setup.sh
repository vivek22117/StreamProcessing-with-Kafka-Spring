#!/usr/bin/env bash

echo "Install Java JDK 8"
yum remove -y java
yum install -y java-1.8.0-openjdk

echo "Install Kafka"
wget -P /home/ec2-user http://apache.mirror.digitalpacific.com.au/kafka/1.1.1/kafka_2.12-1.1.1.tgz
tar xf /home/ec2-user/kafka_2.12-1.1.1.tgz -C /home/ec2-user
ln -s /home/ec2-user/kafka_2.12-1.1.1 /home/ec2-user/kafka
chown -R ec2-user:ec2-user /home/ec2-user/kafka /home/ec2-user/kafka_2.12-1.1.1
rm /home/ec2-user/kafka_2.12-1.1.1.tgz


echo "Configure Kafka Service as Systemd"
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
broker.id=1
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


