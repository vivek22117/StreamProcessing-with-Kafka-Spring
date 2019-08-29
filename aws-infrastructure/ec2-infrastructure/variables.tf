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

variable "ec2-webapp-bucket-key" {
  type    = string
  default = "ec2/codedeploy/rsvp-collection-tier-kafka-kinesis-0.0.1-webapp.zip"
}


variable "rsvp_asg_max_size" {
  type        = "string"
  description = "ASG max size"
}

variable "rsvp_asg_min_size" {
  type        = "string"
  description = "ASG min size"
}

variable "rsvp_asg_desired_capacity" {
  type        = "string"
  description = "ASG desired capacity"
}

variable "rsvp_asg_health_check_grace_period" {
  type        = "string"
  description = "ASG health check grace period"
}

variable "health_check_type" {
  type        = "string"
  description = "ASG health check type"
}

variable "rsvp_asg_wait_for_elb_capacity" {
  type        = "string"
  description = "ASG waith for ELB capacity"
}

variable "default_cooldown" {
  type = number
  description = "Cooldown value of ASG"
}

variable "termination_policies" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated"
  type        = list(string)
}

variable "suspended_processes" {
  description = "The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer"
  type        = list(string)
}

variable "wait_for_capacity_timeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out"
  type        = string
}

variable "app_instance_name" {
  type        = "string"
  description = "Instance name tag to propagate"
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



//Local variables
locals {
  common_tags = {
    owner       = "Vivek"
    team        = "TeamConcept"
    environment = var.environment
  }
}


variable "resource_name_prefix" {
  type        = "string"
  description = "Application resource name prefix"
}

variable "ami_id" {
  type        = "string"
  description = "AMI id to create EC2"
}

variable "instance_type" {
  type        = "string"
  description = "Instance type to launc EC2"
}

variable "key_name" {
  type        = "string"
  description = "Key pair to use SSh access"
}

variable "volume_size" {
  type        = "string"
  description = "Volume size"
}

variable "max_price" {
  type        = "string"
  description = "Spot price for EC2 instance"
}

//ALB
variable "lb_name" {
  type        = "string"
  description = "Name of the load balancer"
}

variable "target_group_path" {
  type        = "string"
  description = "Health check path"
}

variable "target_group_port" {
  type        = "string"
  description = "Port of target group instance"
}