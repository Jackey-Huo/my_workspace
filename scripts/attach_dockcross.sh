#! /bin/bash

mode=$1

echo "mode:  $mode"

docker_name=$(docker ps --format '{{.Image}}\t{{.Names}}' | grep $mode | awk '{print $2}')
echo "mode: $mode, docker_name: $docker_name"

if [[ -z $docker_name ]]; then
  echo "there is no running docker in mode $mode"
else
  docker exec --user=jackey -it $docker_name /bin/bash
fi
