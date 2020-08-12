#!/bin/bash

cd /home/nangjogja/public_html/nangjogja/

docker network create proxy && docker network create internal 
echo "Create Proxy and Internal Network ... \e[32m done\e[0m"

docker-compose up --no-deps -d --scale app=2 --build --remove-orphans
echo "Build Service ... \e[32m done\e[0m"

echo "Service Ready ... \e[32m done\e[0m" && echo "Wait for entrypoint command ... \e[33m on proccess\e[0m"
