#!/bin/bash

# Create RDS
cd rds-terraform
terraform init
terraform apply -auto-approve

# export database credentials for ami
export DB_ENDPOINT=$(terraform output -raw db_endpoint)
export DB_USERNAME=$(terraform output -raw db_username)
export DB_PASSWORD=$(terraform output -raw db_password)
cd ..


# Build AMI
export AWS_PROFILE="iam-profile"
export AWS_REGION="us-west-1"
packer init .
packer build -var "db_endpoint=${DB_ENDPOINT}" \
             -var "db_username=${DB_USERNAME}" \
             -var "db_password=${DB_PASSWORD}" \
             first_packer.pkr.hcl


# Create EC2 instances using AMI
cd ec2-terraform
terraform init
terraform apply -auto-approve