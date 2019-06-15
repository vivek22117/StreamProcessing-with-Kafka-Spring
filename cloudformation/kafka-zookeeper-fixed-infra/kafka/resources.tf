######################################################
# Kafka cluster fixed resources EBS and ENIs
######################################################
resource "aws_ebs_volume" "kafka_cluster_ebs_volumes" {
  count             = "${length(var.kafka_cluster_azs)}"
  availability_zone = "${element(var.kafka_cluster_azs, count.index)}"
  size              = "${var.volume_size_data}"
  type              = "gp2"

  tags = "${merge(local.common_tags, map("Name", "Kafka-EBS-${count.index}"))}"
}


resource "aws_network_interface" "kafka_cluster_enis" {
  count             = "${length(data.terraform_remote_state.vpc.private_subnets)}"

  subnet_id       = "${element(data.terraform_remote_state.vpc.private_subnets, count.index)}"
  private_ips = [ "${element(split(",",var.kafka_private_ips), count.index)}" ]
  security_groups = ["${aws_security_group.kafka_sg.id}"]

  tags = "${merge(local.common_tags, map("Name", "Kafka-ENI-${count.index}"))}"
}


######################################################
# Zookeeper cluster fixed resources EBS and ENIs
######################################################
resource "aws_ebs_volume" "zk_cluster_ebs_volumes" {
  count             = "${length(var.kafka_cluster_azs)}"
  availability_zone = "${element(var.kafka_cluster_azs, count.index)}"
  size              = "${var.volume_size_data}"
  type              = "gp2"

  tags = "${merge(local.common_tags, map("Name", "ZK-EBS-${count.index}"))}"
}

resource "aws_network_interface" "zk_cluster_enis" {
  count             = "${length(data.terraform_remote_state.vpc.private_subnets)}"

  subnet_id       = "${element(data.terraform_remote_state.vpc.private_subnets, count.index)}"
  private_ips = [ "${element(split(",",var.zk_private_ips), count.index)}" ]
  security_groups = ["${aws_security_group.kafka_sg.id}"]

  tags = "${merge(local.common_tags, map("Name", "ZK-ENI-${count.index}"))}"
}