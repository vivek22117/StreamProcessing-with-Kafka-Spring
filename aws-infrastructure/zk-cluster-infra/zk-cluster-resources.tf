resource "random_shuffle" "zk_id" {
  input        = [101, 102, 103, 104, 105]
  result_count = var.zk_cluster_size
}

data "template_file" "zookeeper" {
  template = file("${path.module}/stack/zk-cluster-cft.json")

  vars = {
    volume_id_1 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_ec2_volumes[0]
    volume_id_2 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_ec2_volumes[1]
    volume_id_3 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_ec2_volumes[2]

    eni_id_1 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ids[0]
    eni_id_2 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ids[1]
    eni_id_3 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ids[2]

    zk_ip_1 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips[0]
    zk_ip_2 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips[1]
    zk_ip_3 = data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips[2]

    zk_server_1 = format(
      "%s:%s",
      data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips[0],
      var.zk_internal_port,
    )
    zk_server_2 = format(
      "%s:%s",
      data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips[1],
      var.zk_internal_port,
    )
    zk_server_3 = format(
      "%s:%s",
      data.terraform_remote_state.kafka_fixed_resource.outputs.zk_eni_ips[2],
      var.zk_internal_port,
    )
    sync_limit        = var.sync_limit
    init_limit        = var.init_limit
    tick_time         = var.tick_time
    max_clinet_conn   = var.max_clinet_conn
    kafka_key_pair    = var.kafka_key_pair
    ami_id            = var.ami_id
    ec2_instance_type = var.ec2_instance_type
    name              = "zk-cluster"
    owner_team        = var.owner_team
    environment       = var.environment
    component_name    = var.component_name
  }
}

resource "null_resource" "zk_tags" {
  count = length(var.zk_cluster_size)

  triggers = {
    owner      = "vivek"
    team        = var.owner_team
    environment = var.environment
    Name        = "zk-${count.index}"
  }
}

resource "aws_cloudformation_stack" "zk_cluster" {
  name       = var.cf_stack_name
  on_failure = "DO_NOTHING"

  template_body = data.template_file.zookeeper.rendered
}

