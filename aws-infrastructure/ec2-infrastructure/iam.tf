resource "aws_iam_role" "rsvp_collection_role" {
  name = "RSVPCollectionEC2Role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# create a service role for codedeploy
resource "aws_iam_role" "rsvp_codedeploy_role" {
  name = "RSVPCodeDeployServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#Code deploy access policy
resource "aws_iam_policy" "rsvp_codedeploy_policy" {
  name = "RSVPCodeDeployServicePolicy"
  description = "Policy to access AWS Resources"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:CompleteLifecycleAction",
        "autoscaling:DeleteLifecycleHook",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeLifecycleHooks",
        "autoscaling:PutLifecycleHook",
        "autoscaling:RecordLifecycleActionHeartbeat",
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:UpdateAutoScalingGroup",
        "autoscaling:EnableMetricsCollection",
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribePolicies",
        "autoscaling:DescribeScheduledActions",
        "autoscaling:DescribeNotificationConfigurations",
        "autoscaling:DescribeLifecycleHooks",
        "autoscaling:SuspendProcesses",
        "autoscaling:ResumeProcesses",
        "autoscaling:AttachLoadBalancers",
        "autoscaling:PutScalingPolicy",
        "autoscaling:PutScheduledUpdateGroupAction",
        "autoscaling:PutNotificationConfiguration",
        "autoscaling:PutLifecycleHook",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DeleteAutoScalingGroup",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceStatus",
        "ec2:TerminateInstances",
        "tag:GetTags",
        "tag:GetResources",
        "sns:Publish",
        "cloudwatch:DescribeAlarms",
        "cloudwatch:PutMetricAlarm",
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:DescribeInstanceHealth",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DescribeTargetGroups",
        "elasticloadbalancing:DescribeTargetHealth",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:DeregisterTargets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

}

#RSVP ec2 instance policy
resource "aws_iam_policy" "rsvp_collection_policy" {
  name = "RSVPCollectionEC2Policy"
  description = "Policy to access AWS Resources"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:Put*",
          "kinesis:PutRecords"
      ],
      "Resource": [
        "arn:aws:kinesis:${var.default_region}:${var.aws_account}:stream/${data.terraform_remote_state.rsvp_lambda_kinesis.outputs.stream_name}"
      ]
    },
    {
	  "Action": [
	    "s3:ListBucket"
      ],
	  "Effect": "Allow",
	  "Resource": [
	    "arn:aws:s3:::rsvp-records-${var.environment}",
        "arn:aws:s3:::teamconcept-deploy-*/*",
        "arn:aws:s3:::teamconcept-deploy-*"
			]
	},
	{
	  "Action": [
	    "s3:DeleteObject",
		"s3:Get*",
		"s3:List*",
		"s3:Put*"
	  ],
	  "Effect": "Allow",
	  "Resource": [
	    "arn:aws:s3:::rsvp-records-${var.environment}/*",
        "arn:aws:s3:::teamconcept-deploy-*/*",
        "arn:aws:s3:::teamconcept-deploy-*"
	  ]
	}
  ]
}
EOF

}

#Code deploy policy role attachement
resource "aws_iam_role_policy_attachment" "codedeployo_policy_role_attach" {
  policy_arn = aws_iam_policy.rsvp_codedeploy_policy.arn
  role       = aws_iam_role.rsvp_codedeploy_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_policy_role_attach" {
  policy_arn = aws_iam_policy.rsvp_collection_policy.arn
  role       = aws_iam_role.rsvp_collection_role.name
}

resource "aws_iam_instance_profile" "rsvp_collection_profile" {
  name = "RSVPCollectionProfile"
  role = aws_iam_role.rsvp_collection_role.name
}

