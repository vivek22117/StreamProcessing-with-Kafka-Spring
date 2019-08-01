resource "random_shuffle" "kafka_id" {
  input        = [101, 102, 103, 104, 105]
  result_count = var.kafka_cluster_size
}

data "template_file" "test" {
  template = file("${path.module}/stack/kafka-cluster-cft.json")

  vars = {
    volume_id_1 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_ec2_volumes[0]
    volume_id_2 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_ec2_volumes[1]
    volume_id_3 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_ec2_volumes[2]

    eni_id_1 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_eni_ids[0]
    eni_id_2 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_eni_ids[1]
    eni_id_3 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_eni_ids[2]

    kafka_ip_1 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_eni_ips[0]
    kafka_ip_2 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_eni_ips[1]
    kafka_ip_3 = data.terraform_remote_state.kafka_fixed_resource.outputs.kafka_eni_ips[2]

    is_monitoring_enabled  = var.is_monitoring_enabled
    broker_id_1            = random_shuffle.kafka_id.result[0]
    broker_id_2            = random_shuffle.kafka_id.result[1]
    broker_id_3            = random_shuffle.kafka_id.result[2]
    topic_deletion_enabled = var.topic_deletion_enabled
    num_partition          = var.num_partition
    default_replication    = var.default_replication
    min_insync_replica     = var.min_insync_replica
    log_retention          = var.log_retention
    zookeeper_private_ips = join(
      ",",
      formatlist(
        "%s:%s",
        data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips,
        var.zk_port,
      )
    )
    zk_connection_timeout = var.zk_connection_timeout
    auto_create_topic     = var.auto_create_topic
    offset_replication    = var.offset_replication
    kafka_key_pair        = var.kafka_key_pair
    ami_id                = var.ami_id
    ec2_instance_type     = var.ec2_instance_type
    name                  = "Kafka-cluster"
    owner_team            = var.owner_team
    environment           = var.environment
    component_name        = var.component_name
  }
}

resource "null_resource" "kafka_tags" {
  count = length(var.kafka_cluster_size)

  triggers = {
    ownner      = "vivek"
    team        = var.owner_team
    environment = var.environment
    Name        = "Kafka-${count.index}"
  }
}

resource "aws_cloudformation_stack" "kafka_cluster" {
  name       = var.cf_stack_name
  on_failure = "DO_NOTHING"

  template_body = data.template_file.test.rendered
}

