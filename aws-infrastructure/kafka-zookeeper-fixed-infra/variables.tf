//Global Variables
variable "profile" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = string
  description = "AWS Profile name for credentials"
}

variable "volume_size_data" {
  type        = string
  description = "size of ebs block"
}

variable "kafka_cluster_size" {
  type        = string
  description = "Kafka cluster size"
}

variable "zk_quoram_size" {
  type        = string
  description = "Kafka zookeeper size"
}

//Default Variables
variable "default_region" {
  type    = string
  default = "us-east-1"
}

variable "kafka_private_ips" {
  type    = string
  default = "10.0.1.5,10.0.3.5,10.0.5.5"
}

variable "zk_private_ips" {
  type    = string
  default = "10.0.1.6,10.0.3.6,10.0.5.6"
}

variable "kafka_cluster_azs" {
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

