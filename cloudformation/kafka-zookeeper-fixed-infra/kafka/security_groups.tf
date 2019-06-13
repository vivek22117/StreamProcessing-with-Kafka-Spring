// Security Group for Jenkins Master
resource "aws_security_group" "kafka_sg" {
  name        = "KafkaSecurityGroup"
  description = "Kafka security group to allow traffic"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${local.common_tags}"
}

resource "aws_security_group_rule" "allow_traffic_from_8080" {
  description = "Allow traffic from port 8080 for JMX"
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kafka_sg.id}"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_traffic" {
  description = "Allow ssh traffic from bastion"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kafka_sg.id}"
  source_security_group_id = "${data.terraform_remote_state.vpc.bastion_sg}"
}

resource "aws_security_group_rule" "allow_traffic_from_8778" {
  description = "Allow traffic from Jolokia port"
  type              = "ingress"
  from_port         = 8778
  to_port           = 8778
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kafka_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_traffic_from_9092" {
  description = "Allow traffic from kafka external port"
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kafka_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_traffic_from_9999" {
  description = "Allow traffic from kafka external port"
  type              = "ingress"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kafka_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

