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


# Database security group
resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  vpc_id = "vpc-0b11df27e8f3533a1"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# VPC subnet for Database
resource "aws_db_subnet_group" "mysql_subnet" {
  name = "mysql-subnet-group"
  subnet_ids = [
    "subnet-0b0d34f4e7cd94128",
    "subnet-041a911d4831aa155"
  ]
}


variable "db_username" {
  type = string
  default = "admin"
}

variable "db_password" {
  type = string
  default = "mypassword"
}

# RDS mysql
resource "aws_db_instance" "mysql-db" {
  identifier = "devop-db"
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  username = var.db_username
  password = var.db_password
  db_name = "files"
  port = 3306

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.mysql_subnet.name

  skip_final_snapshot = true
}