.PHONY: helper

all: build

build:
	cd tools && bash init_swarm.sh

update:
	# USAGE: make update echo='hi'
	docker service update --env-add ECHO="$(echo)" app

scale:
	# USAGE: make scale n=5
	docker service scale app=$(n)
