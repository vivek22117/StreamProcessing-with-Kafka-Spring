//Global Variables
variable "profile" {
  type        = "string"
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = "string"
  description = "AWS Profile name for credentials"
}

variable "owner_team" {
  type = "string"
  description = "Name of owner team"
}

variable "component_name" {
  type = "string"
  description = "Component name for resources"
}

// Kafka variables
variable "kafka_cluster_size" {
  type = "string"
  description = "Kafka cluster size"
}

variable "zk_cluster_size" {
  type = "string"
  description = "Zookeeper cluster size"
}

variable "is_monitoring_enabled" {
  type = "string"
  description = "Monitoring enabled or not in EC2"
}

variable "topic_deletion_enabled" {
  type = "string"
  description = "Deteltion of kafka topic is enabled or not"
}

variable "num_partition" {
  type = "string"
  description = "Number of partition for specific topic"
}

variable "default_replication" {
  type = "string"
  description = "Default replication factor for each partition"
}

variable "min_insync_replica" {
  type = "string"
  description = "Minimum insync replicas"
}

variable "log_retention" {
  type = "string"
  description = "Log retention hours in kafka"
}

variable "zk_connection_timeout" {
  type = "string"
  description = "Zookeeper connection timeout"
}

variable "auto_create_topic" {
  type = "string"
  description = "Auto create kafka topic enabled or not"
}

variable "offset_replication" {
  type = "string"
  description = "Offset replication factor"
}

variable "ami_id" {
  type = "string"
  description = "AMI id for ec2 instance"
}

variable "ec2_instance_type" {
  type = "string"
  description = "EC2 instance type"
}

//Default Variables
variable "default_region" {
  type    = "string"
  default = "us-east-1"
}

variable "cf_stack_name" {
  type = "string"
  description = "Kafka cluster stack name"
  default = "kafka-cluster-stack"
}

variable "logical_id" {
  type = "string"
  description = "Logical Id for EC2 instance resource in CFT"
  default = "KafkaClusterInstance"
}

variable "waitcondition_logical_id" {
  type = "string"
  description = "Wait condition logical id for AWS resource in CFT"
  default = "KafkaWaitCondition"
}

variable "zk_port" {
  type = "string"
  description = "Zookeeper external port"
  default = "2181"
}

variable "kafka_key_pair" {
  type = "string"
  description = "Kafka ec2 instance key pair"
  default = "kafka-key"
}

variable "private_ips" {
  type = "string"
  default = "10.0.0.5,10.0.2.5,10.0.4.5"
}

variable "kafka_cluster_azs" {
  type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "dyanamoDB_prefix" {
  type    = "string"
  default = "teamconcept-tfstate"
}

variable "s3_bucket_prefix" {
  type    = "string"
  default = "teamconcept-tfstate"
}

//Local variables
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = "${var.environment}"
  }
}
