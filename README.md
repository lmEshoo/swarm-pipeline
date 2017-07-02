# docker-swarm-cicd

![simple_cicd](https://user-images.githubusercontent.com/3256544/27766479-ddbe89e4-5e85-11e7-9406-4429615377c8.png)

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
