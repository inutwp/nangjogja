#!/bin/bash

HOMEPATH="/home/nangjogja/public_html/nangjogja"
IMAGE="inutwp/nangjogja"

cd ${HOMEPATH}

echo "Down all Service"
docker-compose down && docker container prune -f

docker images | grep -E ${IMAGE}
isImageNangJogjaExists=$?
if [ $isImageNangJogjaExists -eq 0 ]; then
	echo "Remove Image"
	docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${IMAGE})
fi

echo "Clear Image Redundant"
docker image prune -f

echo "Logs Config"
LOGPATHS=(
${HOMEPATH}/log/nginx.log
${HOMEPATH}/log/traefik.log
${HOMEPATH}/log/access_traefik.log
${HOMEPATH}/log/access_nginx.log
)

for LOGPATH in ${LOGPATHS[@]}; do
	if [ ! -e ${LOGPATH} ]; then
		echo ${LOGPATH} "Not Found, Create One"
		touch ${LOGPATH}
	else
		echo ${LOGPATH} "Clear Log File"
		truncate -s 0 ${LOGPATH}
	fi
done

echo "Create Proxy and Internal Network"
docker network rm proxy internal && docker network prune -f
docker network create proxy && docker network create internal

echo "Build Service"
docker-compose up -d --no-deps --build --remove-orphans
resultBuild=$?
if [ $resultBuild -eq 0 ]; then
	echo "Service Ready" && echo "Wait for Entrypoint"
else
	echo "Error Start Service"
	sleep 2

	echo "Re-Run Script"
	bash ${HOMEPATH}/startup.sh
fi
