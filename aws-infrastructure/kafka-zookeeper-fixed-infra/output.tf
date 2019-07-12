output "kafka_eni_ips" {
  value = aws_network_interface.kafka_cluster_enis.*.private_ip
}

output "kafka_eni_ids" {
  value = aws_network_interface.kafka_cluster_enis.*.id
}

output "kafka_ec2_volumes" {
  value = aws_ebs_volume.kafka_cluster_ebs_volumes.*.id
}

output "kafka_sg" {
  value = aws_security_group.kafka_sg.id
}

output "zk_eni_ips" {
  value = aws_network_interface.zk_cluster_enis.*.private_ip
}

output "zk_eni_ids" {
  value = aws_network_interface.zk_cluster_enis.*.id
}

output "zk_ec2_volumes" {
  value = aws_ebs_volume.zk_cluster_ebs_volumes.*.id
}

output "zk_sg" {
  value = aws_security_group.zookeeper_sg.id
}

