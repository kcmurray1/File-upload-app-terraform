terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version= "~>4.16"
      }
    }
    required_version = ">=1.2.0"
}

provider "aws" {
  region = "us-west-1"
  profile = "iam-profile"
}

variable "vpc_id" {
  default = "vpc-0b11df27e8f3533a1"
}

# Create s3 bucket
resource "aws_s3_bucket" "devop-bucket-01" {
  bucket = "devop-bucket-01"
  force_destroy = true
  
  tags = {
    Name = "devop-bucket-01"
    Environment = "Dev"
  }
}

# Create Webserver security group
resource "aws_security_group" "server-sg" {
  name = "web-sg"
  description ="Allow HTTP and SSH"

  vpc_id = "vpc-0b11df27e8f3533a1"

  # inbound ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound http
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  
  # Outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ami we created with Packer
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["dropbox-clone-*"]
    }

    owners = ["905317844151"]
}


resource "aws_iam_role" "ec2_role" {
  name = "ec2-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3-least_privilege" {
  name = "awd"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::devop-bucket-01"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::devop-bucket-01/*"
        }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-app-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "server" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  subnet_id = "subnet-03aedbeb3576eca33"
  key_name = "west_key"
  count = 2
  user_data = file("ec2_boot.sh")
  tags = {
    Name = "MyWebServer"
  }
}