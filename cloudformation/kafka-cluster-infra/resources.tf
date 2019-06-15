data "template_file" "test" {
  count = "${length(var.kafka_cluster_size)}"
  template = "${file("${path.module}/stack/kafka-cluster-cft.json")}"

  vars {
    logical_id = "${var.logical_id}${count.index}"
    waitcondition_logical_id = "${var.waitcondition_logical_id}${count.index}"

    is_monitoring_enabled = "${var.is_monitoring_enabled}"

    broker_id = "${count.index}"
    broker_private_ip = "${element(data.terraform_remote_state.kafka_fixed_resource.kafka_eni_ips, count.index)}"
    topic_deletion_enabled = "${var.topic_deletion_enabled}"
    num_partition = "${var.num_partition}"
    default_replication = "${var.default_replication}"
    min_insync_replica = "${var.min_insync_replica}"
    log_retention = "${var.log_retention}"
    zookeeper_private_ips = "${join(",", formatlist("%s:%s",data.terraform_remote_state.kafka_fixed_resource.zk_eni_ips, var.zk_port))}"
    zk_connection_timeout = "${var.zk_connection_timeout}"
    auto_create_topic = "${var.auto_create_topic}"
    offset_replication = "${var.offset_replication}"
    kafka_key_pair = "${var.kafka_key_pair}"
    ami_id = "${var.ami_id}"
    ec2_instance_type = "${var.ec2_instance_type}"
    eni_id = "${element(data.terraform_remote_state.kafka_fixed_resource.kafka_eni_ids, count.index)}"

    name = "Kafka-${count.index}"
    owner_team = "${var.owner_team}"
    environment = "${var.environment}"
    component_name = "${var.component_name}"

  }
}

resource "null_resource" "kafka_tags" {
  count = "${length(var.kafka_cluster_size)}"

  triggers {
    ownner     = "vivek"
    team = "${var.owner_team}"
    environment = "${var.environment}"
    Name = "Kafka-${count.index}"
  }
}

resource "aws_cloudformation_stack" "kafka_cluster" {
  name = "${var.cf_stack_name}"
  on_failure = "DO_NOTHING"

  template_body = "${data.template_file.test.rendered}"
}
