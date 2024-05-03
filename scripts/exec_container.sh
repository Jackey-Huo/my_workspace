#!/usr/bin/env bash
#
# Run commands in a running container.
# Without any arguments to keep interactive.
#
# Example:
#   Get inside the default container:
#     $ ./exec_container.sh
#   Get inside [test] container:
#     $ ./exec_container.sh test
#   Run `bazel test //common/time:time_test` without get inside the container:
#     $ ./exec_container.sh -- bazel test //common/time:time_test

set -e

# Use argument $1 as $NAME.
NAME=${1:-${NAME}}

# Check if the container exists.
if ! docker ps -a --format "{{.Names}}" | grep -q "^$NAME$"; then
  echo "Container [$NAME] does not exist"
  exit 1
fi
# Check if the container is running.
if ! docker ps --format "{{.Names}}" | grep -q "^$NAME$"; then
  echo "Starting container [$NAME] ..."
  docker start $NAME >/dev/null
fi

# Allow docker to connect to the X server.
if [[ "$DOCKER_WITH_X" -eq 1 ]]; then
  xhost +local:docker >/dev/null
fi

  #-u $USER \
  #-e USER \
docker exec -it \
  -u $USER \
  -e USER \
  $NAME \
  /bin/zsh
