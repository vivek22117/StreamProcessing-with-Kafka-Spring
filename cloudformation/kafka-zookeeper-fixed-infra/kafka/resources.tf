resource "aws_ebs_volume" "data-ebs-volumes" {
  count             = "${length(var.kafka_cluster_azs)}"
  availability_zone = "${element(var.kafka_cluster_azs, count.index)}"
  size              = "${var.volume_size_data}"
  type              = "gp2"

  tags = "${merge(local.common_tags, map("Name", "Kafka-EBS-${count.index}"))}"
}

resource "aws_network_interface" "kafka_cluster_privateIP_1" {
  count             = "${length(data.terraform_remote_state.vpc.private_subnets)}"

  subnet_id       = "${element(data.terraform_remote_state.vpc.private_subnets, count.index)}"
  private_ips = [ "${element(split(",",var.private_ips), count.index)}" ]
  security_groups = ["${aws_security_group.kafka_sg.id}"]

  tags = "${merge(local.common_tags, map("Name", "ENI-${count.index}"))}"
}