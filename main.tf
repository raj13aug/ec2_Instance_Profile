# Declaring the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "role" {
  name = "test_role"

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

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.role.name
}


resource "aws_iam_policy" "policy" {
  name        = "iam-policy-for-instance-role"
  description = "iam-policy-for-instance-role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*","s3:Get*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-s3-test-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.test_profile.id

  tags = {
    Name = "Instance_profile"
  }
}
