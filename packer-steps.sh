#!/bin/bash
sleep 30

set -e

# Update environment
sudo apt-get update -y
sudo apt-get upgrade -y

# Install important tools
sudo apt-get install -y python3-pip python3-venv git nginx supervisor pkg-config libmysqlclient-dev mysql-client

# Clone Django project
git clone https://github.com/kcmurray1/file-upload-app.git

# Setup Virtual Environment
python3 -m venv env
source env/bin/activate

# Switch the project directory
cd file-upload-app/
pip install --upgrade pip

# Install Python Packages
pip install -r requirements.txt
pip install gunicorn

# create static files
cd /home/ubuntu/file-upload-app/datastore
python manage.py collectstatic

# setup gunicorn 
cd /home/ubuntu
sudo mv gunicorn.conf /etc/supervisor/conf.d/
sudo mkdir /var/log/gunicorn

# start gunicorn using supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status

# 2) setup nginx 
sudo sed -i 's/www-data/root/g' /etc/nginx/nginx.conf

# Point Nginx to Django Project
cd /home/ubuntu
sudo mv django.conf /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo ln /etc/nginx/sites-available/django.conf /etc/nginx/sites-enabled/
sudo service nginx restart
