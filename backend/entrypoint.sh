#!/bin/bash

# Wait for database to be ready
echo "Waiting for database..."
echo "Trying to connect to $DB_HOST:$DB_PORT"
while ! nc -z $DB_HOST $DB_PORT; do
  echo "Database not ready, waiting..."
  sleep 1
done
echo "Database started"

# Create migrations if they don't exist
echo "Creating migrations..."
python manage.py makemigrations

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