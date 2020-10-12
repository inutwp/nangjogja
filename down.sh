#!/bin/sh

cd /home/nangjogja/public_html/nangjogja/

docker-compose down && docker image prune -f && docker service rm nangjogja_portainer nangjogja_traefik nangjogja_app
echo "Down Service ... \e[32m done\e[0m"

docker images | grep -E 'inutwp/nangjogja'
isImageNangJogjaExists=$?
if [ $isImageNangJogjaExists -eq 0 ]; then
	echo "Remove Image"
	docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep 'inutwp/nangjogja')
fi

docker image prune -f && docker container prune -f
echo "Clear Redundant ... \e[32m done\e[0m"

truncate -s 0 /home/nangjogja/public_html/nangjogja/log/nginx.log
truncate -s 0 /home/nangjogja/public_html/nangjogja/log/traefik.log
truncate -s 0 /home/nangjogja/public_html/nangjogja/log/access_traefik.log
truncate -s 0 /home/nangjogja/public_html/nangjogja/log/access_nginx.log
echo "Clear Log ... \e[32m done\e[0m"

echo "All Service Down ... \e[32m done\e[0m"
