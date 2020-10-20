#!/bin/bash

source .env
cd ${HOMEDIR}
clear

if [[ ${LOG_DIR} == *"../"* ]]; then
	LOG_DIR=${LOG_DIR:(-3)}
else
	LOG_DIR=${LOG_DIR}
fi

DOCKERFILE="${BUILD_DIR}/Dockerfile"
FILE_COMPOSE_BASE="${BUILD_DIR}/docker-compose.yml"
FILE_COMPOSE_SWARM="${BUILD_DIR}/docker-swarm.yml"

COMPOSE="docker-compose -f ${FILE_COMPOSE_BASE}"

clearImage() {
	docker images | grep -E ${IMAGE} 2> /dev/null
	if [ $? -eq 0 ]; then
		echo "Remove Image"
		docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${IMAGE}) -f 2> /dev/null
	fi

	docker image prune -f 2> /dev/null
	docker container prune -f 2> /dev/null
}

createNetwork() {
	MODE="$1"

	if [[ ${MODE} == 'swarm' ]]; then
		NETWORKS=(
		internal:overlay
		proxy:overlay
		)
	else
		NETWORKS=(
		internal:bridge
		proxy:bridge
		)
	fi

	for NETWORK in ${NETWORKS[@]}; do
		NETWORKNAME=$(echo ${NETWORK} | cut -d':' -f 1)
		NETWORKDRIVER=$(echo ${NETWORK} | cut -d':' -f 2)

		docker network ls | grep -E '${NETWORKNAME}.*${NETWORKDRIVER}' 2> /dev/null
		CHECKNETWORK=$?
		if [ ${CHECKNETWORK} -eq 0 ]; then
			checkNetwork=isset
		else
			checkNetwork=empty
		fi

		if [[ ${MODE} == 'swarm' ]]; then
			if [[ ${checkNetwork} == 'isset' ]]; then
				echo "Swarm Network ${NETWORKNAME} is Exists"
			else
				echo "Swarm Network ${NETWORKNAME} no Exists, Run create Swarm Network ${NETWORKNAME}"
				docker network create -d overlay ${NETWORKNAME} 2> /dev/null
				if [ $? -eq 0 ]; then
					echo "Swarm Network ${NETWORKNAME} Created"
				else
					docker network rm ${NETWORKNAME} 2> /dev/null
					docker network create -d overlay ${NETWORKNAME} 2> /dev/null
					echo "Swarm Network ${NETWORKNAME} Created"
				fi
			fi
		else
			if [[ ${checkNetwork} == 'isset' ]]; then
				echo "Local Network ${NETWORKNAME} is Exists"
			else
				echo "Local Network ${NETWORKNAME} no Exists, Run create Local Network ${NETWORKNAME}"
				docker network create -d bridge ${NETWORKNAME} 2> /dev/null
				if [ $? -eq 0 ]; then
					echo "Local Network ${NETWORKNAME} Created"
				else
					docker network rm ${NETWORKNAME} 2> /dev/null
					docker network create -d bridge ${NETWORKNAME} 2> /dev/null
					echo "Local Network ${NETWORKNAME} Created"
				fi
			fi
		fi
	done
}

build() {
	echo 'Run Compose'

	docker service ls | grep -E "nangjogja_"
	if [ $? -eq 0 ]; then
		echo "Down all Service"
		docker service rm nangjogja_portainer nangjogja_traefik nangjogja_app 2> /dev/null
		${COMPOSE} down 2> /dev/null
	fi 

	docker ps | grep -E "build_"
	if [ $? -eq 0 ]; then
		echo "Down all Compose"
		${COMPOSE} down 2> /dev/null
	fi

	docker container prune -f  2> /dev/null

	LOGPATHS=(
	${HOMEDIR}/${LOG_DIR}/nginx.log
	${HOMEDIR}/${LOG_DIR}/traefik.log
	${HOMEDIR}/${LOG_DIR}/access_traefik.log
	${HOMEDIR}/${LOG_DIR}/access_nginx.log
	)
	for LOGPATH in ${LOGPATHS[@]}; do
		if [ ! -e ${LOGPATH} ]; then
			echo ${LOGPATH} "File Not Found, Create One"
			touch ${LOGPATH}
			CHECKTOUCH=$?
			if [ ${CHECKTOUCH} -gt 0 ]; then
				echo "Directory not Exist, Please Check Again"
				exit
			fi
		else
			echo ${LOGPATH} "Clear Log File"
			truncate -s 0 ${LOGPATH}
		fi
	done

	createNetwork

	docker build --file ${DOCKERFILE} .
	${COMPOSE} up -d --no-deps --build --remove-orphans 
	resultBuild=$?
	if [ $resultBuild -eq 0 ]; then
		echo "Service Ready" && echo "Wait for Entrypoint"
	else
		echo "Error Start Service"
		exit
	fi
}

deploy() {
	echo 'Run Deploy'

	docker service ls | grep -E "nangjogja_"
	if [ $? -eq 0 ]; then
		echo "Down all Service"
		docker service rm nangjogja_portainer nangjogja_traefik nangjogja_app 2> /dev/null
	fi 
		
	${COMPOSE} down
	if [ $? -eq 0 ]; then
		docker container prune -f 2> /dev/null 
	else
		echo "Error Down Compose, Please Check Again"
		exit
	fi

	echo 'Pulling Image'
	docker pull ${IMAGE}:${IMAGE_TAG} 2> /dev/null
	if [ $? -gt 0 ]; then
		echo "Error Pulling Image ${IMAGE}:${IMAGE_TAG}, Please Check Again"
		exit
	fi

	createNetwork 'swarm'

	docker stack deploy --prune --compose-file ${FILE_COMPOSE_SWARM} ${APP_NAME}
	if [ $? -eq 0 ]
	then
		sleep 2
		echo "Deploy Success"
		docker stack services ${APP_NAME} 2> /dev/null
	else
		echo "Deploy Error"
	fi
}

down() {
	echo 'Run Down'

	docker service ls | grep -E "nangjogja_" 2> /dev/null
	if [ $? -eq 0 ]; then
		echo "Down Service"
		docker service rm nangjogja_portainer nangjogja_traefik nangjogja_app 2> /dev/null
	else
		docker ps | grep -E "build_" 2> /dev/null
		if [ $? -eq 0 ]; then
			echo "Star Down Compose"
			${COMPOSE} down 
		else
			echo "All Compose Down"
			exit
		fi
	fi 

	# clearImage

	docker network ls | grep -E 'proxy|internal' 
	if [ $? -eq 0 ]; then
		echo "Remove Network"
		docker network rm proxy internal
		if [ $? -eq 0 ]; then
			echo "Prune Network"
			docker network prune -f 2> /dev/null
		else
			echo "Cant Remove Network, Please Check Again"
			exit
		fi
	else
		echo "Skip Remove Network"
	fi

	echo "Clear Logs"
	LOGFILES=(
	nginx.log
	traefik.log
	access_traefik.log
	access_nginx.log
	)
	for LOGFILE in ${LOGFILES[@]}; do
		LOGPATH=${HOMEDIR}/${LOG_DIR}/${LOGFILE}
		if [ ! -e ${LOGPATH} ]; then
			echo ${LOGPATH} "File Not Found"
			continue
		else
			truncate -s 0 ${LOGPATH}
			echo "File ${LOGFILE} Clear"
		fi
	done

	echo "All Service Down"
}


if [ "$1" == swarm ]; then
	docker service ls | grep -E 'nangjogja_' 2> /dev/null
	if [ $? -eq 0 ]; then
		read -p "Swarm is Exist, Are you sure you want to re-deploy [${IMAGE}]? (y/N) " -r
	    echo
	    if [[ $REPLY =~ ^[Yy]$ ]]; then
			deploy
	    fi 
	else
		docker ps | grep -E 'build_' 2> /dev/null
		if [ $? -eq 0 ]; then
			read -p "Compose is Exist, Are you sure you want to down compose and deploy [${IMAGE}]? (y/N) " -r
		    echo
		    if [[ $REPLY =~ ^[Yy]$ ]]; then
				deploy
		    fi 
		else
			deploy
		fi
	fi
elif [ "$1" == down ]; then
	docker service ls | grep -E 'nangjogja_' 2> /dev/null
	if [ $? -eq 0 ]; then
		read -p "Swarm is Exist, Are you sure you want to down [${IMAGE}]? (y/N) " -r
	    echo
	    if [[ $REPLY =~ ^[Yy]$ ]]; then
			down
	    fi 
	else
		docker ps | grep -E 'build_' 2> /dev/null
		if [ $? -eq 0 ]; then
			read -p "Compose is Exist, Are you sure you want to down [${IMAGE}]? (y/N) " -r
		    echo
		    if [[ $REPLY =~ ^[Yy]$ ]]; then
				down
		    fi 
		else
			down
		fi
	fi
else
	docker service ls | grep -E 'nangjogja_' 2> /dev/null
	if [ $? -eq 0 ]; then
		read -p "Swarm is Exist, Are you sure you want to deploy [${IMAGE}]? (y/N) " -r
	    echo
	    if [[ $REPLY =~ ^[Yy]$ ]]; then
			build
	    fi 
	else
		docker ps | grep -E 'build_' > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			read -p "Compose is Exist, Are you sure you want to deploy [${IMAGE}]? (y/N) " -r
		    echo
		    if [[ $REPLY =~ ^[Yy]$ ]]; then
				build
		    fi 
		else
			build
		fi
	fi
fi