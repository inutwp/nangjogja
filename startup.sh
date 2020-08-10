#!/bin/bash

cd /home/nangjogja/public_html/nangjogja/

echo "+++++++++++++++++++++++++++++++++++++++ Create Proxy and Internal Network ++++++++++++++++++++++++++++++++++++++"
	docker network create proxy && docker network create internal

echo "+++++++++++++++++++++++++++++++++++++++ Build App ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	docker-compose up --no-deps -d --build --remove-orphans && docker-compose ps

echo "+++++++++++++++++++++++++++++++++++++++ Clear Redundant ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	docker image prune -y && docker container prune -y

echo "+++++++++++++++++++++++++++++++++++++++ App Ready, Wait for supervisord ++++++++++++++++++++++++++++++++++++++++"