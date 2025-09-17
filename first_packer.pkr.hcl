packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name = "dropbox-clone-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "${var.my_region}"
  source_ami_filter {
    filters = {
      name                = "${var.source_ami_name}"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

variable "db_endpoint" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = true
}


build {
  name    = "file-upload-app-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
     inline = [
      "cd /home/ubuntu/",
      "echo \"DB_HOST=${var.db_endpoint}\" >> .env",
      "echo \"DB_USER=${var.db_username}\" >> .env",
      "echo \"DB_PASSWORD=${var.db_password}\" >> .env"
    ]
  }

  provisioner "file" {
    source = "gunicorn.conf"
    destination = "/home/ubuntu/gunicorn.conf"
  }
  provisioner "file" {
    source = "django.conf"
    destination = "/home/ubuntu/django.conf"
  }
  provisioner "shell" {
    script = "./packer-steps.sh"
  }
}

variable "my_region" {
  type = string
  default = "us-west-1"
}



variable "source_ami_name" {
  type = string
  default ="ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}