#!/bin/bash

cd /var/www/
composer install --optimize-autoloader
cp .env.example .env
php artisan key:generate
php artisan optimize
php artisan storage:link
chown -R www:www /var/www/
chmod -R 0644 /var/www/
find /var/www/ -type d -print0 | xargs -0 chmod 0755

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
