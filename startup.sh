#!/bin/bash

HOMEPATH="/home/nangjogja/public_html/nangjogja/"
IMAGE="inutwp/nangjogja"

cd "${HOMEPATH}"

echo "Down all Service"
docker-compose down && docker container prune -f

docker images | grep -E ${IMAGE}
isImageNangJogjaExists=$?
if [ $isImageNangJogjaExists -eq 0 ]; then
	echo "Remove Image"
	docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${IMAGE})
fi

echo "Clear Redundant"
docker image prune -f

echo "Clear Logs"
LOGPATHS=(
${HOMEPATH}/log/nginx.log 
${HOMEPATH}/log/traefik.log 
${HOMEPATH}/log/access_traefik.log 
${HOMEPATH}/log/access_nginx.log
)

for LOGPATH in ${LOGPATHS[@]}; do
	if [ ! -e ${LOGPATH} ]; then
		echo ${LOGPATH} "Not Found"
	else
		truncate -s 0 ${LOGPATH} 
	fi
done

docker network rm proxy internal && docker network prune -f
docker network create proxy && docker network create internal 
echo "Create Proxy and Internal Network"

docker-compose up --no-deps -d --build --remove-orphans
echo "Build Service"

echo "Service Ready" && echo "Wait for entrypoint"