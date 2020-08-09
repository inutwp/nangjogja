#!/bin/bash

cd /home/nangjogja/public_html/nangjogja/

echo "+++++++++++++++++++++++++++++++++++++++ Down Service ++++++++++++++++++++++++++++++++++++++"
	docker-compose down

echo "+++++++++++++++++++++++++++++++++++++++ Clear Redundant ++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	docker image prune -f && docker container prune -f && docker network prune -f && docker volume prune -f

echo "+++++++++++++++++++++++++++++++++++++++ Clear Log ++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	truncate -s 0 /home/nangjogja/public_html/nangjogja/log/nginx.log
	truncate -s 0 /home/nangjogja/public_html/nangjogja/log/traefik.log
	truncate -s 0 /home/nangjogja/public_html/nangjogja/log/access_traefik.log
	truncate -s 0 /home/nangjogja/public_html/nangjogja/log/access_nginx.log

echo "+++++++++++++++++++++++++++++++++++++++ All Service Down ++++++++++++++++++++++++++++++++++++++++"