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


//Default Variables
variable "default_region" {
  type    = string
  default = "us-east-1"
}

variable "dyanamoDB_prefix" {
  type    = string
  default = "teamconcept-tfstate"
}

variable "s3_bucket_prefix" {
  type    = string
  default = "teamconcept-tfstate"
}

variable "app_instance_name" {
  type        = "string"
  description = "Instance name tag to propagate"
}

//Local variables
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = var.environment
  }
}
