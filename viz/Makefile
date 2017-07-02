.PHONY: helping hand

IMAGE=dockersamples/visualizer
CONTAINER_NAME=swarm-viz

all: run

run:
	sudo docker run -it --name $(CONTAINER_NAME) -d -p 5100:8080 -v /var/run/docker.sock:/var/run/docker.sock $(IMAGE)
stop:
	sudo docker stop $(CONTAINER_NAME)
	sudo docker rm $(CONTAINER_NAME)
