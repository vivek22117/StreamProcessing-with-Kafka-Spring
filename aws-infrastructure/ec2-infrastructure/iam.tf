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
        "${data.terraform_remote_state.rsvp_lambda_kinesis.outputs.kinesis_arn}"
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

resource "aws_iam_role_policy_attachment" "ec2_policy_role_attach" {
  policy_arn = aws_iam_policy.rsvp_collection_policy.arn
  role       = aws_iam_role.rsvp_collection_role.name
}

resource "aws_iam_instance_profile" "rsvp_collection_profile" {
  name = "RSVPCollectionProfile"
  role = aws_iam_role.rsvp_collection_role.name
}

