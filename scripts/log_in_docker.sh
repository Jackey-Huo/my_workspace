#!/usr/bin/env bash

NOT_RUN_SHELL=$1
NAME="xxx"

if ! docker ps --format "{{.Names}}" | grep -q "^$NAME$"; then
  echo "Container [$NAME] does no exist, restart it"
  if docker ps -a --format "{{.Names}}" | grep -q "^$NAME$"; then
    echo "Remove container [$NAME] ..."
  docker rm $NAME
  fi
  cd ~/My_Project/my_workspace
  ./scripts/create_container.sh jackey_dev $NAME
fi

if [[ $NOT_RUN_SHELL != "not_run_shell" ]]; then
  echo "attach into docker zsh..."
  cd ~/My_Project/my_workspace
  ./scripts/exec_container.sh $NAME
else
  echo "create container only, do not attach into docker"
fi 
