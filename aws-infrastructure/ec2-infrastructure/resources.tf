# adding the zip/jar to the defined bucket
resource "aws_s3_bucket_object" "ec2-app-package" {
  bucket                 = data.terraform_remote_state.backend.outputs.deploy_bucket_name
  key                    = var.ec2-webapp-bucket-key
  source                 = "${path.module}/CollectionTier-Kafka/target/rsvp-collection-tier-kafka-kinesis-0.0.1-webapp.zip"
  server_side_encryption = "AES256"
}

resource "aws_launch_template" "rsvp_launch_template" {
  name_prefix            = "${var.resource_name_prefix}${var.environment}"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = base64decode(data.template_file.ec2_user_data.rendered)

  instance_initiated_shutdown_behavior = "terminate"

  iam_instance_profile {
    arn = aws_iam_instance_profile.rsvp_collection_profile.arn
  }

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price = var.max_price
    }
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  placement {
    tenancy = "default"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb" "rsvp_lb" {
  name               = var.lb_name
  load_balancer_type = "network"
  subnets            = [split(",", data.terraform_remote_state.vpc.outputs.private_subnets)]
  internal           = "true"

  tags {
    Name = "${var.lb_name}-${var.environment}"
  }
}

resource "aws_lb_listener" "rsvp_lb_listener" {
  load_balancer_arn = aws_lb.rsvp_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.rsvp_lb_target_group.arn
    type             = "forward"
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  depends_on   = ["aws_lb_target_group.rsvp_lb_target_group"]
  listener_arn = aws_lb_listener.rsvp_lb_listener.arn
  priority     = "100"
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rsvp_lb_target_group.arn
  }
  condition {
    field  = "path-pattern"
    values = ["/"]
  }
}

resource "aws_lb_target_group" "rsvp_lb_target_group" {
  name     = "${var.resource_name_prefix}-${var.environment}-tg"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id

  tags {
    name = "${var.resource_name_prefix}-tg"
  }

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = var.target_group_path
    port                = var.target_group_port
  }
}

resource "aws_autoscaling_group" "rsvp_asg" {
  name_prefix         = "rsvp-asg-${var.environment}"
  vpc_zone_identifier = [split(",", data.terraform_remote_state.vpc.outputs.private_subnets)]

  launch_template = {
    id      = aws_launch_template.rsvp_launch_template.id
    version = aws_launch_template.rsvp_launch_template.latest_version
  }
  target_group_arns = [aws_lb_target_group.rsvp_lb_target_group.arn]

  termination_policies      = ["OldestInstance"]
  max_size                  = var.rsvp_asg_max_size
  min_size                  = var.rsvp_asg_min_size
  desired_capacity          = var.rsvp_asg_desired_capacity
  health_check_grace_period = var.rsvp_asg_health_check_grace_period
  health_check_type         = var.health_check_type
  load_balancers            = [aws_lb.rsvp_lb.name]
  wait_for_elb_capacity     = var.rsvp_asg_wait_for_elb_capacity

  tag {
    key                 = "Name"
    value               = var.app_instance_name
    propagate_at_launch = true
  }

  tag {
    key                 = "owner"
    value               = local.common_tags.owner
    propagate_at_launch = true
  }

  tag {
    key                 = "team"
    value               = local.common_tags.team
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "attach_rsvp_asg_tg" {
  autoscaling_group_name = aws_autoscaling_group.rsvp_asg.id
  alb_target_group_arn   = aws_lb_target_group.rsvp_lb_target_group.arn
}

resource "aws_autoscaling_policy" "instance_scaling_policy" {
  autoscaling_group_name = aws_autoscaling_group.rsvp_asg.name
  name                   = "rsvp_asg_scaling_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}

