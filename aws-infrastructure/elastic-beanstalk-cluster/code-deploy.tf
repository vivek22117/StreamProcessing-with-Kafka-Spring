# create a CodeDeploy application
resource "aws_codedeploy_app" "main" {
  name = "Sample_App"
}

# create a deployment group
resource "aws_codedeploy_deployment_group" "main" {
  app_name              = aws_codedeploy_app.main.name
  deployment_group_name = "RSVPCollectionTier"
  service_role_arn      = aws_iam_role.rsvp_codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.OneAtATime"                      # AWS defined deployment config

  ec2_tag_filter = {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = var.app_instance_name
  }

  # trigger a rollback on deployment failure event
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE",
    ]
  }
}