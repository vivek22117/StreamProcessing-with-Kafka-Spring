data "terraform_remote_state" "kafka_fixed_resource" {
  backend = "s3"

  config {
    profile = "doubledigit"
    bucket  = "${var.s3_bucket_prefix}-${var.environment}-${var.default_region}"
    key     = "state/${var.environment}/kafka/fixed-resource/terraform.tfstate"
    region  = "${var.default_region}"
  }
}
