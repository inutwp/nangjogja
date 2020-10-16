#!/bin/bash

HOMEPATH="/home/nangjogja/public_html/nangjogja/"
IMAGE="inutwp/nangjogja"

cd ${HOMEPATH}

echo "Down Service"
docker-compose down && docker image prune -f && docker service rm nangjogja_portainer nangjogja_traefik nangjogja_app

docker images | grep -E ${IMAGE}
isImageNangJogjaExists=$?
if [ $isImageNangJogjaExists -eq 0 ]; then
	echo "Remove Image"
	docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${IMAGE})
fi

echo "Clear Redundant"
docker image prune -f && docker container prune -f

echo "Clear Logs"
LOGPATHS=(
${HOMEPATH}/log/nginx.log
${HOMEPATH}/log/traefik.log
${HOMEPATH}/log/access_traefik.log
${HOMEPATH}/log/access_nginx.log
)

for LOGPATH in ${LOGPATHS[@]}; do
	if [ ! -e ${LOGPATH} ]; then
		echo ${LOGPATH} "File Not Found"
		continue
	else
		truncate -s 0 ${LOGPATH}
	fi
done

echo "All Service Down"
