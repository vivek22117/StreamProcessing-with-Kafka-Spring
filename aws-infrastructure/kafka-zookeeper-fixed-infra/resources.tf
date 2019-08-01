######################################################
# Kafka cluster fixed resources EBS and ENIs
######################################################
resource "aws_ebs_volume" "kafka_cluster_ebs_volumes" {
  count = var.kafka_cluster_size

  availability_zone = var.kafka_cluster_azs[count.index]
  size              = var.volume_size_data
  type              = "gp2"

  tags = merge(
    local.common_tags,
    {
      Name = "Kafka-EBS-${count.index}"
    }
  )
}

resource "aws_network_interface" "kafka_cluster_enis" {
  count = var.kafka_cluster_size

  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[count.index]
  private_ips     = [split(",", var.kafka_private_ips)[count.index]]
  security_groups = [aws_security_group.kafka_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "Kafka-ENI-${count.index}"
    }
  )
}

######################################################
# Zookeeper cluster fixed resources EBS and ENIs
######################################################
resource "aws_ebs_volume" "zk_cluster_ebs_volumes" {
  count = var.zk_quoram_size

  availability_zone = var.kafka_cluster_azs[count.index]
  size              = var.volume_size_data
  type              = "gp2"

  tags = merge(
    local.common_tags,
    {
      Name = "ZK-EBS-${count.index}"
    }
  )
}

resource "aws_network_interface" "zk_cluster_enis" {
  count = var.zk_quoram_size

  subnet_id = data.terraform_remote_state.vpc.outputs.public_subnets[count.index]
  private_ips     = [split(",", var.zk_private_ips)[count.index]]
  security_groups = [aws_security_group.zookeeper_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "ZK-ENI-${count.index}"
    }
  )
}

