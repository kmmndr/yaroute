# https://github.com/kmmndr/makefile-collection

DOCKER_IMAGE?=localhost/application
DOCKER_TAG?=latest
DOCKER_CONTEXT?=.
DOCKER_FILE?=Dockerfile
DOCKER_CACHE_ARGS?=
DOCKER_BUILD_ARGS=--build-arg SOURCE_IMAGE=${DOCKER_IMAGE}
DOCKER?=docker

export DOCKER_BUILDKIT = 1

.PRECIOUS: Dockerfile%
Dockerfiles: Dockerfile
	dockerfile_splitter -base-image ${DOCKER_IMAGE}

DOCKER_FILES=$(wildcard Dockerfile-*)

docker-pull-tagged-image:
	${DOCKER} pull ${DOCKER_IMAGE}:${DOCKER_TAG}
docker-pull-tagged-image%:
	${DOCKER} pull ${DOCKER_IMAGE}:${DOCKER_TAG}$*
docker-pull-all-tagged-images: $(DOCKER_FILES:Dockerfile%=docker-pull-tagged-image%)

docker-pull-latest-image:
	-${DOCKER} pull ${DOCKER_IMAGE}:latest
docker-pull-latest-image%:
	-${DOCKER} pull ${DOCKER_IMAGE}:latest$*
docker-pull-all-latest-images: $(DOCKER_FILES:Dockerfile%=docker-pull-latest-image%)

docker-image: Dockerfile
	${DOCKER} build ${DOCKER_BUILD_ARGS} ${DOCKER_CACHE_ARGS} --tag ${DOCKER_IMAGE}:${DOCKER_TAG} --file $< ${DOCKER_CONTEXT}
docker-image%: Dockerfile%
	${DOCKER} build ${DOCKER_BUILD_ARGS} ${DOCKER_CACHE_ARGS} --tag ${DOCKER_IMAGE}:${DOCKER_TAG}$* --file $< ${DOCKER_CONTEXT}
docker-all-images: $(DOCKER_FILES:Dockerfile%=docker-image%)

docker-tag-latest-image:
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
docker-tag-latest-image%:
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG}$* ${DOCKER_IMAGE}:latest$*
docker-tag-all-latest-images: $(DOCKER_FILES:Dockerfile%=docker-tag-latest-image%)
docker-tag-latest-image-from-final:
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG}-final ${DOCKER_IMAGE}:latest

docker-push-tagged-image:
	${DOCKER} push ${DOCKER_IMAGE}:${DOCKER_TAG}
docker-push-tagged-image%:
	${DOCKER} push ${DOCKER_IMAGE}:${DOCKER_TAG}$*
docker-push-all-tagged-images: $(DOCKER_FILES:Dockerfile%=docker-push-tagged-image%)

docker-push-latest-image:
	${DOCKER} push ${DOCKER_IMAGE}:latest
docker-push-latest-image%:
	${DOCKER} push ${DOCKER_IMAGE}:latest$*
docker-push-all-latest-images: $(DOCKER_FILES:Dockerfile%=docker-push-latest-image%)

docker-build-image: \
	docker-pull-latest-image \
	docker-image \
	docker-tag-latest-image
docker-build-images: \
	docker-pull-all-latest-images \
	docker-all-images \
	docker-tag-all-latest-images \
	docker-tag-latest-image-from-final
