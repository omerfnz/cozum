#!/bin/bash

# Wait for database to be ready
echo "Waiting for database..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 0.1
done
echo "Database started"

# Run migrations
echo "Running migrations..."
python manage.py migrate

# Create admin user if it doesn't exist
echo "Creating admin user..."
python manage.py create_admin

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Start gunicorn
echo "Starting gunicorn..."
exec gunicorn cozum_var_backend.wsgi:application \
     --bind 0.0.0.0:8000 \
     --workers 4 \
     --worker-class gevent \
     --worker-connections 1000 \
     --max-requests 1000 \
     --max-requests-jitter 100 \
     --timeout 30 \
     --keep-alive 5 \
     --access-logfile - \
     --error-logfile - \
     --log-level info