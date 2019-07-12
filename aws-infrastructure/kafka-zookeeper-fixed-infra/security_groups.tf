#########################################
# Kafka cluster security group
#########################################
resource "aws_security_group" "kafka_sg" {
  name        = "KafkaSecurityGroup"
  description = "Kafka security group to allow traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "Kafka-SG-${data.terraform_remote_state.vpc.outputs.vpc_id}"
    }
  )
}

resource "aws_security_group_rule" "allow_traffic_from_8080" {
  description       = "Allow traffic from port 8080 for JMX"
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_ssh_traffic" {
  description       = "Allow ssh traffic from bastion"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_traffic_from_8778" {
  description       = "Allow traffic from Jolokia port"
  type              = "ingress"
  from_port         = 8778
  to_port           = 8778
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_traffic_from_9092" {
  description       = "Allow traffic from kafka external port"
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_traffic_from_9999" {
  description       = "Allow traffic from kafka external port"
  type              = "ingress"
  from_port         = 9999
  to_port           = 9999
  protocol          = "tcp"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound_kafka" {
  description       = "Allow all outgoing traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.kafka_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

#############################################
# Zookeeper cluster security group
#############################################
resource "aws_security_group" "zookeeper_sg" {
  name        = "ZookeeperSecurityGroup"
  description = "Zookeeper security group to allow traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "ZK-SG-${data.terraform_remote_state.vpc.outputs.vpc_id}"
    }
  )
}

resource "aws_security_group_rule" "allow_traffic_from_2181" {
  description       = "Allow traffic from zookeeper external port"
  type              = "ingress"
  from_port         = 2181
  to_port           = 2181
  protocol          = "tcp"
  security_group_id = aws_security_group.zookeeper_sg.id
  cidr_blocks       = ["10.0.0.0/20"]
}

resource "aws_security_group_rule" "allow_ssh_traffic_zk" {
  description       = "Allow ssh traffic from bastion"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.zookeeper_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_traffic_from_2888" {
  description       = "Allow traffic from zookeeper internal port"
  type              = "ingress"
  from_port         = 2888
  to_port           = 2888
  protocol          = "tcp"
  security_group_id = aws_security_group.zookeeper_sg.id

  cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
}

resource "aws_security_group_rule" "allow_traffic_from_3888" {
  description       = "Allow traffic from zookeeper internal port"
  type              = "ingress"
  from_port         = 3888
  to_port           = 3888
  protocol          = "tcp"
  security_group_id = aws_security_group.zookeeper_sg.id

  cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr]
}

resource "aws_security_group_rule" "allow_all_outbound_zk" {
  description       = "Allow all outgoing traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.zookeeper_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

