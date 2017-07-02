# docker-swarm-cicd

## USAGE

```
make
```

### Prerequisites

- Update `tools/configure.sh` fill the following **required**:
  - `user` is the username of the instance launched
  - `total_managers` is Total number of manager nodes
  - `total_workers` is Total number of worker nodes
  - `manager_ip_1` is initial master node
  - `manager_ip_n` nth initial master node
  - `worker_ip_1` nth initial worker node
  - `worker_ip_n` nth initial worker node
  - be sure that `total_workers` + `total_managers` = number of specified IP addresses
- Update `pem`
  - `cert` is the directory where the Certificate to connect to the instances is located
