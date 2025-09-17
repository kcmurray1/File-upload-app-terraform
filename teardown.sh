#!/bin/bash

cd ec2-terraform/
terraform destroy

cd .. 

cd rds-terraform/
terraform destroy
