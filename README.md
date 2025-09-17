# About
The primary purpose of this project is to document my learning of AWS and Terraform within an independent study environment. This explains some of the hard-coded configurations such as the AWS region and profile.

# Getting Started
[Terraform](https://developer.hashicorp.com/terraform/install) and [Packer](https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli)
must installed in order to use the provided bash scripts to properly use this repository.

Sign in to AWS profile in order to properly run aws commands

## AWS region and Profile
This project uses region us-west-1 and profile "iam-profile". 

## SSH
This project creates 2 EC2 instances that can be accessed through SSH. By default it is open to SSH from any address, you can change it to a personal device if needed.

## How to Run
Stay within the root repository directory and run
```bash
./setup.sh
```
After the script has finished, you can visit the AWS management console and visit any of the EC2 instance public addresses to interact with the Django web application.

## How to stop
Stay within the root repository directory and run
```
./teardown.sh
```
# Infrastructure Design
## Components
### EC2
Hosts the Django application, uses gunicorn as the WSGI server and serves static files with Nginx.
### Gunicorn + Supervisor
Handles Python/Django requests to assist in uploading/reading data from RDS and S3.
### Nginx
Reverse proxy to forward requests from the internet to Gunicorn and serves static assets like CSS and index.
### AWS RDS
MySQL database that stores metadata like filenames, file size, and upload date. Django directly communicates with this DB using environment credentials. 
### AWS S3
Stores files such as videos, pictures, textfiles, etc. Django uses Boto3 and the IAM-role of the EC2 instance to upload, download, and view content within the pre-configured S3 bucket.

