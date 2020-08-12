#!/bin/bash

cd /home/nangjogja/public_html/nangjogja/

docker stack deploy -c docker-compose.yml nangjogja
echo "Deploy ... \e[32m done\e[0m"

sleep 20

docker service ls
docker container ls -a