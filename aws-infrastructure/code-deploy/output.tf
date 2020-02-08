output "rsvp_app_group_name" {
  value = aws_codedeploy_deployment_group.rsvp_codedeploy_group.deployment_group_name
}

output "rsvp_app_name" {
  value = aws_codedeploy_app.rsvp_codedeploy_app.name
}

output "deployment_group_arn" {
  value = aws_codedeploy_deployment_group.rsvp_codedeploy_group.id
}