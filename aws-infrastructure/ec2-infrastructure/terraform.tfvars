profile        = "doubledigit"
environment    = "dev"
owner_team     = "TeamConcept"
component_name = "EC2-Cluster"

resource_name_prefix = "rsvp-collection-tier-"
app_instance_name = "rsvp-collection-tier"

ami_id        = "ami-0cc96feef8c6bbff3"
instance_type = "t2.small"
key_name      = "rsvp-processor-key"
volume_size   = "6"
max_price     = "0.0075"

rsvp_asg_max_size                  = "4"
rsvp_asg_min_size                  = "2"
health_check_type                  = "ELB"
rsvp_asg_health_check_grace_period = "60"
rsvp_asg_wait_for_elb_capacity     = "2"


lb_name           = "rsvp-collection-tier-lb"
target_group_path = "/actuator/health"
target_group_port = "2020"