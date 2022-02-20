#!/usr/bin/env bash

NAME="xxx"

if ! docker ps --format "{{.Names}}" | grep -q "^$NAME$"; then
  echo "Container [$NAME] does no exist, restart it"
  if docker ps -a --format "{{.Names}}" | grep -q "^$NAME$"; then
    echo "Remove container [$NAME] ..."
  docker rm $NAME
  fi
  cd /Users/jackey/My_Project/my_workspace
  ./scripts/create_container.sh jackey_dev $NAME
fi

cd /Users/jackey/My_Project/my_workspace
./scripts/exec_container.sh $NAME
