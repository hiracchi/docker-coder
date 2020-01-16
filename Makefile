PACKAGE=registry.gitlab.com/hiracchi/docker-coder
TAG=2.1692
CONTAINER_NAME=coder

#DEBUG_CMD=tail -f /dev/null

.PHONY: all build

all: build

build:
	docker build \
		-f Dockerfile \
		-t "${PACKAGE}:${TAG}" . 2>&1 | tee build.log

start:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker run -d \
		--name ${CONTAINER_NAME} \
		--user ${USER_ID}:${GROUP_ID} \
		--volume "${PWD}/work:/work" \
		-p "8443:8443" \
		"${PACKAGE}:${TAG}" ${DEBUG_CMD}
	@sleep 1
	docker ps -a

#--rm \

stop:
	docker rm -f ${CONTAINER_NAME}


restart: stop start


term:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker exec -it ${CONTAINER_NAME} \
		/bin/bash


logs:
	docker logs ${CONTAINER_NAME}
