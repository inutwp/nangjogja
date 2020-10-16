#!/bin/bash

cd /home/nangjogja/public_html/nangjogja/

checkImageNangJogjaisExists=$( docker images | grep -E 'inutwp/nangjogja' )
isImageNangJogjaExists=$?
if [ $isImageNangJogjaExists -eq 0 ]
then
	echo "Image nangjogja is Exists"
else
	echo "Pulling Image..."
	docker pull inutwp/nangjogja:v1.6.0
fi

checkInternalNetworkisExists=$( docker network ls | grep -E 'internal.*overlay' )
isInternalNetworkExists=$?
if [ $isInternalNetworkExists -eq 0 ]
then
	echo "Internal Network is Exists"
else
	echo "Internal Network no Exists, Run create Internal Network"
	docker network create -d overlay internal
	if [ $? -eq 0 ]
	then
		echo "Internal Network Created"
	else
		docker network rm internal
		docker network create -d overlay internal
	fi
fi

checkProxyNetworkisExists=$( docker network ls | grep -E 'proxy.*overlay' )
isProxyNetworkExists=$?
if [ $isProxyNetworkExists -eq 0 ]
then
	echo "Proxy Network is Exists"
else
	echo "Proxy Network no Exists, Run create Proxy Network"
	docker network create -d overlay proxy
	if [ $? -eq 0 ]
	then
		echo "Proxy Network Created"
	else
		docker network rm proxy
		docker network create -d overlay proxy
	fi
fi

echo "Run Deploy..."
runDeploy=$( docker stack deploy -c docker-swarm.yml nangjogja )
isDeploySuccess=$?
if [ $isDeploySuccess -eq 0 ]
then
	echo "Deploy Sucess... \e[32m done\e[0m"
	sleep 3
	docker service ls
else
	echo "Deploy Error... \e[31m error\e[0m"
fi
