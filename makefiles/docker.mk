# https://github.com/kmmndr/makefile-collection

DOCKER_IMAGE?=localhost/application
DOCKER_TAG?=latest
DOCKER_CONTEXT?=.
DOCKER_FILE?=Dockerfile
DOCKER_CACHE_FROM_IMAGE?=--cache-from ${DOCKER_IMAGE}
DOCKER_BUILD_ARGS=--build-arg SOURCE_IMAGE=${DOCKER_IMAGE}
DOCKER?=docker

export DOCKER_BUILDKIT = 1

Dockerfiles: Dockerfile
	dockerfile_splitter -base-image ${DOCKER_IMAGE}

DOCKERFILES=$(wildcard Dockerfile-*)

docker-pull-tagged-image:
	${DOCKER} pull ${DOCKER_IMAGE}:${DOCKER_TAG}
docker-pull-tagged-image-%:
	${DOCKER} pull ${DOCKER_IMAGE}:${DOCKER_TAG}-$*
docker-pull-tagged-images: $(DOCKERFILES:Dockerfile-%=docker-pull-tagged-image-%)

docker-pull-latest-image:
	-${DOCKER} pull ${DOCKER_IMAGE}:latest
docker-pull-latest-image-%:
	-${DOCKER} pull ${DOCKER_IMAGE}:latest-$*
docker-pull-latest-images: $(DOCKERFILES:Dockerfile-%=docker-pull-latest-image-%)

docker-build-image: Dockerfile docker-pull-latest-image
	${DOCKER} build ${DOCKER_BUILD_ARGS} ${DOCKER_CACHE_FROM_IMAGE}:latest --tag ${DOCKER_IMAGE}:${DOCKER_TAG} --file $< ${DOCKER_CONTEXT}
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
docker-build-image-%: Dockerfile-% docker-pull-latest-image-%
	${DOCKER} build ${DOCKER_BUILD_ARGS} ${DOCKER_CACHE_FROM_IMAGE}:latest-$* --tag ${DOCKER_IMAGE}:${DOCKER_TAG}-$* --file $< ${DOCKER_CONTEXT}
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG}-$* ${DOCKER_IMAGE}:latest-$*
docker-build-images: $(DOCKERFILES:Dockerfile-%=docker-build-image-%)
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG}-final ${DOCKER_IMAGE}:${DOCKER_TAG}
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest

docker-tag-from-final:
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG}-final ${DOCKER_IMAGE}:${DOCKER_TAG}
	${DOCKER} tag ${DOCKER_IMAGE}:${DOCKER_TAG}-final ${DOCKER_IMAGE}:latest

docker-push-tagged-image:
	${DOCKER} push ${DOCKER_IMAGE}:${DOCKER_TAG}
docker-push-tagged-image-%:
	${DOCKER} push ${DOCKER_IMAGE}:${DOCKER_TAG}-$*
docker-push-tagged-images: $(DOCKERFILES:Dockerfile-%=docker-push-tagged-image-%)

docker-push-latest-image:
	${DOCKER} push ${DOCKER_IMAGE}:latest
docker-push-latest-image-%:
	${DOCKER} push ${DOCKER_IMAGE}:latest-$*
docker-push-latest-images: $(DOCKERFILES:Dockerfile-%=docker-push-latest-image-%)

docker-push-image:   docker-push-tagged-image   docker-push-latest-image ;
docker-push-image-%: docker-push-tagged-image-% docker-push-latest-image-% ;

docker-build-push-image:   docker-build-image   docker-push-image ;
docker-build-push-image-%: docker-build-image-% docker-push-image-% ;
