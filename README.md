# My vim docker

## Usage

```bash
docker build --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) --build-arg USERNAME=$(id -u -n) --build-arg USER_GROUP_NAME=$(id -g -n) -t jackey_dev  -f dev.dockerfile artifact/docker
./scripts/create_container.sh jackey_dev xxx
./scripts/exec_container.sh xxx
```
