CODER_VERSION=3.2.0
PACKAGE=registry.gitlab.com/hiracchi/docker-coder
TAG=${CODER_VERSION}
CONTAINER_NAME=coder

#DEBUG_CMD=tail -f /dev/null

.PHONY: all build

all: build

build:
	docker build \
		-f Dockerfile \
		-t "${PACKAGE}:${TAG}" \
		--build-arg CODER_VERSION="${CODER_VERSION}" \
		. 2>&1 | tee build.log

start:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker run -d \
		--rm \
		--name ${CONTAINER_NAME} \
		--user ${USER_ID}:${GROUP_ID} \
		--volume "${PWD}/work:/work" \
		-p "8080:8080" \
		"${PACKAGE}:${TAG}" ${DEBUG_CMD}


stop:
	docker rm -f ${CONTAINER_NAME}


restart: stop start


term:
	@\$(eval USER_ID := $(shell id -u))
	@\$(eval GROUP_ID := $(shell id -g))
	docker exec -it ${CONTAINER_NAME} \
		/bin/bash


logs:
	docker logs -f ${CONTAINER_NAME}
