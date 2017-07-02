#!/bin/bash
source configure.sh
source nodes_ids.cfg

if [ $1 = "up" ]; then
  echo "Starting APP."

  if [ "$2" = "none" ]; then
    echo "INFO: Bypassing ";
  else
    docker service create --name=$3 --network $swarm_network \
    --replicas 2 --env ECHO="HI" -p 5000:5000 --detach=true $2
  fi

elif [ $1 = "stats" ]; then
  echo "no stats"
else
  if [ "$2" = "none" ]; then
    echo "INFO: Bypassing ";
  else
    sudo docker service rm app
  fi

fi
