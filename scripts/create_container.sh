#!/usr/bin/env bash
#
# Create a docker container on given docker image and set up basic user
# development environment.
#
# Example:
#   Create [Libra] container on image [dev]:
#     $ ./create_container.sh
#   Create [test] container on image [libra-test]:
#     $ ./create_container.sh libra-test test

set -e

# Use argument $1 as $IMG.
# Use argument $2 as $NAME.
IMG=${1:-${IMG}}
NAME=${2:-${NAME}}

# The directory contains current script.
DIR=$(dirname $(realpath "$BASH_SOURCE"))
# The directory contains .git directory.
REPO_DIR=${REPO_DIR:-$(
  d=$DIR
  while [[ $d != / ]]; do
    [[ -d $d/.git ]] && echo $d && break
    d=$(dirname "$d")
  done
)}
[[ -d $REPO_DIR ]] || (
  echo >&2 "Failed to find working directory"
  exit 1
)

# Set default $IMG and $NAME.
work_dir_basename=$(basename $REPO_DIR)
if [[ -z $IMG ]]; then
  # Change camel case to lowercase with dashes(-).
  IMG=$(echo $work_dir_basename | sed 's/[A-Z]/-&/g' | sed 's/^-//')
  IMG=${IMG,,}-dev
  if [[ -z $(docker images -f "reference=$IMG:latest" --format='{{.Tag}}') ]]; then
    IMG=harbor.dreame.com/$IMG
  fi
fi
if [[ -z $NAME ]]; then
  NAME=$work_dir_basename
fi

# Check if the image exists.
if [[ -z $(docker images -f "reference=$IMG" --format='{{.Tag}}') ]]; then
  echo >&2 "Failed to find the image [$IMG]"
  exit 1
fi

# Check if the container exists.
if docker ps -a --format "{{.Names}}" | grep -q "^$NAME$"; then
  echo >&2 "Container [$NAME] is already existing"
  echo >&2 "Run 'docker stop $NAME && docker rm $NAME' before creating new one"
  exit 1
fi

echo "Creating container [$NAME] on image [$IMG] ..."

# Prepare cache path.
mkdir -p $HOME/.cache
DOCKER_HOME=/home/$USER

# Create container.
docker run -i -d --name $NAME \
  --privileged \
  --net host \
  --hostname in_docker \
  --add-host in_docker:127.0.0.1 \
  --add-host $(hostname):127.0.0.1 \
  --pid host \
  --shm-size 2G \
  -v /etc/localtime:/etc/localtime:ro \
  -v /usr/src:/usr/src \
  -v /lib/modules:/lib/modules \
  -v $HOME/.ssh:$DOCKER_HOME/.ssh \
  -v $HOME/.cache:$DOCKER_HOME/.cache \
  -v $HOME/.zsh_history:$DOCKER_HOME/.zsh_history \
  -v $HOME/install:$DOCKER_HOME/install \
  -v $HOME/My_Project/dreame:$DOCKER_HOME/My_Project/dreame \
  -w $DOCKER_HOME \
  $IMG \
  /bin/bash

docker exec $NAME /bin/bash -c \
  'printf "\n\n180.163.151.33 dl.google.com\n192.168.10.10 jfrog.dreame.com\n192.168.10.10 git.dreame.com" >> /etc/hosts'

echo "Container [$NAME] has been created"

# Add current user and group inside the container.
#if [[ "$USER" != "root" ]]; then
  #echo "Adding user [$USER] inside the container ..."
  #docker cp $DIR/docker_adduser.sh $NAME:/tmp
  #docker exec \
    #-e DOCKER_USER=$USER \
    #-e DOCKER_USER_ID=$(id -u) \
    #-e DOCKER_GRP=$(id -g -n) \
    #-e DOCKER_GRP_ID=$(id -g) \
    #$NAME \
    #bash -c "/tmp/docker_adduser.sh >/dev/null && rm /tmp/docker_adduser.sh"
  #echo "Done"
#fi

#docker exec -u $USER \
       #$NAME \
       #/bin/bash -c "set -x && cd $DOCKER_HOME && ln -s -f /root/.vim* . && ln -s -f /root/.zsh* ."
