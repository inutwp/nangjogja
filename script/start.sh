#!/bin/bash

cd /var/www/
cp .env.example .env
composer install --optimize-autoloader
php /var/www/artisan key:generate
php /var/www/artisan storage:link
php /var/www/artisan optimize
chown -R www:www /var/www/
chmod -R 0644 /var/www/
find /var/www/ -type d -print0 | xargs -0 chmod 0755

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
