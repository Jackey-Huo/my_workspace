# My vim docker

## Usage

```bash
docker build -t jackey_dev  -f dev.dockerfile artifact/docker
./scripts/create_container.sh jackey_dev xxx
./scripts/exec_container.sh xxx
```
