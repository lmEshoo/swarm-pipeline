#!/bin/bash
source configure.sh
source pem

sleep 1;

#Install on all managers
for i in $(seq 1 $total_managers) ; do

  name="manager_ip_"$i
  ip=${!name}
  echo -e "\n\n INFO: Working on $name | $ip \n"
  [ $ip ] || { echo "ERROR: No IP Address found for $name" && continue; }
  sleep 1;
  #create folders and configure
  ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    bash -c " :
    sudo yum -y update;
    sudo yum install -y firewalld git;
    sudo curl -sSL https://get.docker.com/ | sh;
    sudo systemctl enable docker;
    sudo systemctl start docker;
    sudo systemctl enable firewalld;
    sudo systemctl start firewalld;
    sudo systemctl status firewalld;
    sudo firewall-cmd --permanent --add-port=2377/tcp
    sudo firewall-cmd --permanent --add-port=7946/tcp
    sudo firewall-cmd --permanent --add-port=7946/udp
    sudo firewall-cmd --permanent --add-port=4789/udp
    sudo firewall-cmd --reload;
    sudo chmod 777 /var/run/docker.sock;"

done

sleep 2;

#Install on all workers
for i in $(seq 1 $total_workers) ; do
  name="worker_ip_"$i
  ip=${!name}
    echo -e "\n\n INFO: Working on $name | $ip \n"
  [ $ip ] || { echo "ERROR: No IP Address found for $name" && continue; }
  sleep 1;
  #create folders
  ssh -o "StrictHostKeyChecking no" -i "$cert" ${user}@${ip} \
    bash -c " :
    sudo yum -y update;
    sudo yum install -y firewalld git;
    sudo curl -sSL https://get.docker.com/ | sh;
    sudo systemctl enable docker;
    sudo systemctl start docker;
    sudo systemctl enable firewalld;
    sudo systemctl start firewalld;
    sudo systemctl status firewalld;
    sudo firewall-cmd --permanent --add-port=2377/tcp
    sudo firewall-cmd --permanent --add-port=7946/tcp
    sudo firewall-cmd --permanent --add-port=7946/udp
    sudo firewall-cmd --permanent --add-port=4789/udp
    sudo firewall-cmd --reload;"
done
