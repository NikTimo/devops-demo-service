#!/bin/sh
python manage.py migrate
python manage.py collectstatic
python manage.py createsuperuser --noinput --username $DJANGO_SUPERUSER_USERNAME --email $DJANGO_SUPERUSER_EMAIL
gunicorn --workers=1 --bind $SERVICE_HOST:$SERVICE_PORT devops_demo.wsgi