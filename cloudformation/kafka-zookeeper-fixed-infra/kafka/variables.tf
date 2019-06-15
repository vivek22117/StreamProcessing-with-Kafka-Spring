//Global Variables
variable "profile" {
  type        = "string"
  description = "AWS Profile name for credentials"
}

variable "environment" {
  type        = "string"
  description = "AWS Profile name for credentials"
}

variable "volume_size_data" {
  type = "string"
  description = "size of ebs block"
}


//Default Variables
variable "default_region" {
  type    = "string"
  default = "us-east-1"
}

variable "kafka_private_ips" {
  type = "string"
  default = "10.0.0.5,10.0.2.5,10.0.4.5"
}

variable "zk_private_ips" {
  type = "string"
  default = "10.0.0.6,10.0.2.6,10.0.4.6"
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
