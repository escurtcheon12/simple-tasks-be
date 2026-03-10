#!/bin/sh
set -e

# Replace port in nginx config
sed -i "s/listen 80/listen ${PORT:-80}/g" /etc/nginx/nginx.conf

# Start php-fpm in the background
php-fpm -D

# Start nginx in the foreground
nginx -g 'daemon off;'
