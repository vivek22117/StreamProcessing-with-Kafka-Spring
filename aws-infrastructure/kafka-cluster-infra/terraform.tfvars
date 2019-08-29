profile = "doubledigit"
environment = "dev"
owner_team = "TeamConcept"
component_name = "Kafka-Cluster"

kafka_cluster_size = "3"
log_retention = "10"
is_monitoring_enabled = "true"
topic_deletion_enabled = "true"
min_insync_replica = "2"
num_partition = "3"
default_replication = "3"
zk_connection_timeout = "6000"
auto_create_topic = "false"
offset_replication = "3"


ami_id = "ami-0cc96feef8c6bbff3"
ec2_instance_type = "t2.small"