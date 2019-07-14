resource "aws_iam_role" "rsvp_collection_role" {
  name = "RSVPCollectionRole"
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

resource "aws_iam_policy" "rsvp_collection_policy" {
  name = "RSVPCollectionPolicy"
  description = "Policy to access AWS Resources"
  path = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1476360711000",
      "Effect": "Allow",
      "Action": [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:Put*",
          "kinesis:PutRecords"
      ],
      "Resource": [
        "arn:aws:kinesis:${var.default_region}:${var.aws_account}:stream/rsvp-record-processor-stream"
      ]
    },
    {
	  "Action": [
	    "s3:ListBucket"
      ],
	  "Effect": "Allow",
	  "Resource": [
	    "arn:aws:s3:::rsvp_records_${var.environment}"
			]
	},
	{
	  "Action": [
	    "s3:DeleteObject",
		"s3:Get*",
		"s3:Put*"
	  ],
	  "Effect": "Allow",
	  "Resource": [
	    "arn:aws:s3:::rsvp_records_${var.environment}/*"
	  ]
	}
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "policy_role_attach" {
  policy_arn = aws_iam_policy.rsvp_collection_policy.arn
  role       = aws_iam_role.rsvp_collection_role.name
}

resource "aws_iam_instance_profile" "rsvp_collection_profile" {
  name = "RSVPCollectionProfile"
  role = aws_iam_role.rsvp_collection_role.name
}

