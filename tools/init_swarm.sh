#!/bin/bash
source configure.sh
source pem

start=`date +%s`

bash install-docker.sh

sleep 1;

ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
  sudo docker swarm init --advertise-addr ${manager_ip_1}

sleep 1;

ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
  sudo docker node ls

manager_token=$(ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} sudo docker swarm join-token -q manager)
echo "INFO: Manager's Token: $manager_token";
worker_token=$(ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} sudo docker swarm join-token -q worker)
echo "INFO: Worker's Token: $worker_token";

sleep 1;

#join a manager
for i in $(seq 1 $total_managers) ; do

  name="manager_ip_"$i
  ip=${!name}
  echo -e "\n\n INFO: Working on $name | $ip \n"
  [ $ip ] || { echo "ERROR: No IP Address found for $name" && continue; }
  ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    sudo docker swarm join --token ${manager_token} ${manager_ip_1}:2377 \
    || echo "ERROR: JOINING MANAGER FAILED."
  sleep 1;
  #create folders and configure
  ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    bash -c " :
    sudo service docker stop
    sudo yum update -y docker-engine
    sudo service docker start
    sudo docker info | grep Version
    sudo groupadd docker
    sudo usermod -aG docker $user"
  #get ip
  echo "export SWARM_MASTER_0${i}=${ip}" >> nodes_ids.cfg
  #get node-ID from hostname
  #returns hostname
  hostname=$(ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    bash -c " :
    hostname")
  node_id=$(ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
    bash -c " :
    sudo docker node ls | grep "$hostname)
  echo $(echo -ne "export SWARM_MASTER_0$i""_NODE_ID=" && echo $node_id | awk {'print $1'}) >> nodes_ids.cfg
done

sleep 2;

#join a worker
for i in $(seq 1 $total_workers) ; do
  name="worker_ip_"$i
  ip=${!name}
    echo -e "\n\n INFO: Working on $name | $ip \n"
  [ $ip ] || { echo "ERROR: No IP Address found for $name" && continue; }
  ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    sudo docker swarm join --token ${worker_token} ${manager_ip_1}:2377 \
    || echo "ERROR: JOINING WORKER FAILED."
  sleep 1;
  #create folders
  ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    bash -c " :
    sudo service docker stop
    sudo yum update -y docker-engine
    sudo service docker start
    sudo docker info | grep Version
    sudo groupadd docker
    sudo usermod -aG docker $user"
  #get ip
  echo "export SWARM_WORKER_0${i}=${ip}" >> nodes_ids.cfg
  #get node-ID from hostname
  #returns hostname
  hostname=$(ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    bash -c " :
    hostname")
  node_id=$(ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
    bash -c " :
    sudo docker node ls | grep "$hostname)
  echo $(echo -ne "export SWARM_WORKER_0$i""_NODE_ID=" && echo $node_id | awk {'print $1'}) >> nodes_ids.cfg
done

sleep 2;

ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} sudo docker node ls

#scp everything over
scp -i "$cert" -r ../../swarm-pipeline/ ${user}@${manager_ip_1}:/home/${user}/

ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
  bash -c " :
  sudo chmod 777 /var/run/docker.sock
  cd /home/$user/swarm-pipeline/viz/ && make"

while [[ ! `curl -sf http://${manager_ip_1}:5100` ]]; do echo "INFO: Starting Viz"; sleep 5; done
open http://${manager_ip_1}:5100

#scp new configs
scp -i "$cert" -r ../../swarm-pipeline/tools ${user}@${manager_ip_1}:/home/${user}/swarm-pipeline/

#create network
ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
  bash -c " :
  cd /home/$user/swarm-pipeline/tools/ && make network;"

#prompt to login to Docker
ssh -o "StrictHostKeyChecking no" -t -i "$cert" ${user}@${manager_ip_1} \
  bash -c " :
  docker login;"

#pull and deploy the dockerized demo app
ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1} \
  bash -c " :
  cd /home/$user && git clone https://github.com/lmEshoo/sample-go-app.git;
  cd /home/$user/swarm-pipeline/tools/ && bash provision_docker_build.sh lmeshoo dockerfile-example"

open http://${manager_ip_1}:5000

end=`date +%s`
runtime=$((end-start))
echo "Total Time: $runtime"

#ssh me in a manager
ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${manager_ip_1}
