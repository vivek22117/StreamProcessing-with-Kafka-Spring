//Global Variables
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "owner_team" {
  type        = string
  description = "Name of owner team"
}

variable "component_name" {
  type        = string
  description = "Component name for resources"
}

// Zookeeper variables
variable "zk_cluster_size" {
  type        = string
  description = "Zookeeper cluster size"
}

variable "ami_id" {
  type        = string
  description = "AMI id for ec2 instance"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "sync_limit" {
  type        = string
  description = "Sync limit for zookeeper"
}

variable "init_limit" {
  type        = string
  description = "Zookeeper init limit"
}

variable "tick_time" {
  type        = string
  description = "It is used for heartbeats and timeouts especially."
}

variable "max_clinet_conn" {
  type        = string
  description = "Maximum allowed client connections for a Zk server. Set this to 0 (unlimited)"
}

//Default Variables
variable "default_region" {
  type    = string
  default = "us-east-1"
}

variable "cf_stack_name" {
  type        = string
  description = "Kafka cluster stack name"
  default     = "zookeeper-cluster-stack"
}

variable "zk_internal_port" {
  type        = string
  description = "Zookeeper internal port"
  default     = "2888:3888"
}

variable "kafka_key_pair" {
  type        = string
  description = "Kafka ec2 instance key pair"
  default     = "kafka-key"
}

variable "zk_cluster_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "dyanamoDB_prefix" {
  type    = string
  default = "teamconcept-tfstate"
}

variable "s3_bucket_prefix" {
  type    = string
  default = "teamconcept-tfstate"
}

//Local variables
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = var.environment
  }
}

