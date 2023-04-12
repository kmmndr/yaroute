#!/bin/sh

stage=${1:-'default'}

cat <<EOF
## base
APP_NAME=yaroute
PROJECT_NAME=yaroute
COMPOSE_PROJECT_NAME=yaroute-$stage
STAGE=$stage
EOF

case $stage in
	'default'|'test')
		cat <<-EOF
		ADMIN_PASSWORD=admin
		EOF
		;;

	'staging'|'production')
		cat <<-EOF
		PROJECT_ENVIRONMENT=$stage
		EOF
		;;

	*)
		echo "Unknown stage $stage"
		exit 1
		;;
esac

if [ "$stage" = "test" ]; then
	cat <<-EOF
	LOCAL_PORT_RAILS=13000
	LOCAL_PORT_CADDY=18080
	LOCAL_PORT_PUMA=19292
	EOF
fi
