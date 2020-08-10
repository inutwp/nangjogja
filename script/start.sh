#!/bin/bash

cd /var/www/
cp .env.example .env
composer install --optimize-autoloader

sed -i -e "s/APP_NAME=Laravel/APP_NAME=nangjogja/g" /var/www/.env
sed -i -e "s/APP_ENV=local/APP_ENV=production/g" /var/www/.env
sed -i -e "s/APP_DEBUG=true/APP_ENV=false/g" /var/www/.env
sed -i -e "s/APP_KEY=/APP_KEY=base64:g4vvYgJLWCSfFOGRKXa7Vwsk2BXkbr8n1PgnWH8vPYY=/g" /var/www/.env
sed -i -e "s#APP_URL=http://localhost#APP_URL=http://nangjogja.gloqi.com#g" /var/www/.env

php /var/www/artisan storage:link
php /var/www/artisan optimize
chown -R www:www /var/www/ && chmod -R 0644 /var/www/
find /var/www/ -type d -print0 | xargs -0 chmod 0755

exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
