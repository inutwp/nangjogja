#!/bin/bash

BASEPATH="/var/www/"
HOMEPATH=${BASEPATH}"nangjogja/"
ENVFILE=${HOMEPATH}".env"
ARTISAN=${HOMEPATH}"artisan"
CONFIGPATH=${HOMEPATH}"config/"
CONFIGFILE=${CONFIGPATH}"opcache.php"
STORAGEPATH=${HOMEPATH}"public/storage/"

cd ${HOMEPATH}
cp .env.example .env

composer install -o

sed -i -e "s/APP_NAME=Laravel/APP_NAME=nangjogja/g" ${ENVFILE}
sed -i -e "s/APP_ENV=local/APP_ENV=production/g" ${ENVFILE}
sed -i -e "s/APP_DEBUG=true/APP_DEBUG=false/g" ${ENVFILE}
sed -i -e "s/APP_KEY=/APP_KEY=base64:g4vvYgJLWCSfFOGRKXa7Vwsk2BXkbr8n1PgnWH8vPYY=/g" ${ENVFILE}
sed -i -e "s#APP_URL=http://localhost#APP_URL=http://nangjogja.gloqi.com#g" ${ENVFILE}

php ${ARTISAN} vendor:publish --provider="Appstract\Opcache\OpcacheServiceProvider" --tag="config" && sleep 2

if [ ! -d ${CONFIGPATH} ]; then
	echo "Delete Config Line, If Config Dir Not Exist"
	sed -i -e "13d" ${CONFIGFILE}
fi

if [ ! -h ${STORAGEPATH} ] && [ ! -L ${STORAGEPATH} ]; then
	echo "Crete Storage Link"
	php ${ARTISAN} storage:link
fi

php ${ARTISAN} config:clear && php ${ARTISAN} optimize

chown -R nangjogja:nangjogja ${BASEPATH} && chmod -R 0644 ${HOMEPATH}
find ${HOMEPATH} -type d -print0 | xargs -0 chmod 0755

/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf