#!/bin/bash
source /home/ubuntu/env/bin/activate
cd /home/ubuntu/file-upload-app/datastore
python manage.py makemigrations datastoreapp
python manage.py migrate