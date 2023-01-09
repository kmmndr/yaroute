REGISTRY_PROJECT_URL ?= localhost/yaroute
BUILD_SUBPATH ?=dev
# BUILD_ID = commit_sha
BUILD_ID ?=$(shell test -d .git && git rev-parse HEAD | cut -c -8)
# REF_ID = branch_name
REF_ID ?=$(shell test -d .git \
	 && git symbolic-ref --short HEAD \
	 | sed -e 's/[^a-z0-9]/-/g' -e 's/^[-+]//' -e 's/[-+]$$//' \
	 | cut -c 1-62)

default: help
include makefiles/*.mk

## CI

ci-build: docker-pull docker-build
ci-push: docker-push
ci-push-release: docker-pull-final docker-push-release
ci-test: test-most test-system

## Tests

test-most:
	@$(MAKE) dockerized-test-setup
	@$(MAKE) -e stage=test dockerized-rails-test
	@$(MAKE) dockerized-test-teardown

test-system:
	@$(MAKE) dockerized-test-setup
	@$(MAKE) -e stage=test dockerized-rails-test-system
	@$(MAKE) dockerized-test-teardown

.PHONY: set-test-docker-compose-files
set-test-docker-compose-files:
	$(eval compose_files=-f docker-compose.yml -f docker-compose.test.yml)
	$(eval TEST_IMAGE?=${REGISTRY_PROJECT_URL}/${BUILD_SUBPATH}:${BUILD_ID}-test)

dockerized-test-setup:
	@$(MAKE) -e stage=test generate-env dockerized-test-init

dockerized-test-init: environment test-docker-compose-clean
	@$(load_env); \
		set -eux; \
		export TEST_IMAGE=${TEST_IMAGE}; \
		${COMPOSE} ${compose_files} up -d; \
		${COMPOSE} ${compose_files} run rails bundle exec sh -c " \
			rm -rf coverage; \
			bundle exec rake active_storage:bucket:reset; \
			bundle exec rake db:migrate \
		"

dockerized-test-teardown:
	@$(MAKE) -e stage=test test-docker-compose-clean

test-docker-compose-clean: set-test-docker-compose-files docker-compose-clean

.PHONY: dockerized-rails-test
dockerized-rails-test: environment set-test-docker-compose-files
	@$(load_env); \
		set -eux; \
		export TEST_IMAGE=${TEST_IMAGE}; \
		${COMPOSE} ${compose_files} run rails \
			env RAILS_ENV=test bundle exec rake test

.PHONY: dockerized-rails-test-system
dockerized-rails-test-system: environment set-test-docker-compose-files
	@$(load_env); \
		set -eux; \
		export TEST_IMAGE=${TEST_IMAGE}; \
		${COMPOSE} ${compose_files} run rails \
			env RAILS_ENV=test bundle exec rake test:system

## Deployments

.PHONY: build
build: docker-compose-build

.PHONY: start
start: docker-compose-pull docker-compose-start ##- Start

.PHONY: deploy
deploy: deploy-docker ##- alias for deploy-docker

.PHONY: deploy-docker
deploy-docker: docker-compose-pull docker-compose-deploy

.PHONY: stop
stop: docker-compose-stop ##- Stop

## Debug

.PHONY: logs
logs: docker-compose-logs ##- Logs

.PHONY: clean
clean: docker-compose-clean ##- Stop and remove volumes

.PHONY: status
status: docker-compose-ps ##- Print container's status

.PHONY: load-database
load-database: environment database.sql ##- Load database
	$(load_env); echo -n "Restoring database to stage '${stage}' (Enter 'YES' to continue) ? "; $(eval ok?=ko) (["${stage}"="${ok}"] || read ok); [ "$$ok" == 'YES' ]
	@$(load_env); pv database.sql | ${COMPOSE} exec -e PGPASSWORD=$$APP_DATABASE_PASSWORD -T postgres psql -U $$APP_DATABASE_USER -h localhost -d $$APP_DATABASE_NAME > /dev/null

.PHONY: dump-database
dump-database: environment ##- Dump database
	@$(load_env); ${COMPOSE} exec -e PGPASSWORD=$$APP_DATABASE_PASSWORD -T postgres pg_dump -U $$APP_DATABASE_USER -h localhost -d $$APP_DATABASE_NAME --clean | pv > database.sql

.PHONY: console
console: environment ##- Enter console
	-$(load_env); ${COMPOSE} ${compose_files} exec rails /bin/ash

.PHONY: local-start
local-start: set-local-docker-compose-files docker-compose-build docker-compose-start ##- Build and start
	@$(load_env); ${COMPOSE} exec rails sh -c "[ -x ./docker.local.sh ] && sudo ./docker.local.sh; true"

.PHONY: local-ports
local-ports: environment ##- Display available local ports
	@echo 'Local ports:'
	@$(load_env); env | grep LOCAL_PORT | sed -e 's/^LOCAL_PORT_/ - /' -e 's/=/: /'
