#!/usr/bin/env bash

# All error are fatal
set -e

CONTAINER="moijimobile/ecstatic:6.1"

# Drive the ecstatic docker image to update the content for us.


##
# Runs the ecstatic generator through docker
function run_docker() {
	docker run \
		--cap-add SYS_NICE \
		--rm -it -v "$(pwd)":/opt \
		"${docker_args[@]}" \
		-w /opt \
		${CONTAINER} bash /ecstatic/ecstatic "${docker_cmd[@]}"
}

##
# Makes a release to the docs/ folder
function make_release() {
	rm -rf _site
	rm -rf docs
	generate
	rm _site/README.md _site/ecstatic.sh
	find _site/ -name "*.pillar" -delete
	mv _site docs/

	# Restore the CNAME
	git checkout docs/CNAME
}

##
# Generates the content into the _site/ folder
function generate() {
	docker_args=()
	docker_cmd=(generate)
	run_docker
}

##
# Generates and serves the data locally
function serve() {
	generate

	docker_args=(-p 8080:8080)
	docker_cmd=(serve -p 8080)
	#docker_cmd=(serve -w -p 8080)
	run_docker
}

case "$1" in
	release)
		make_release
		;;

	generate)
		generate
		;;

	serve)
		serve
		;;
	*)
		echo "Use one of release|generate|serve commands."
		;;
esac
