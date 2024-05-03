#!/usr/bin/env bash

# 同步各类设置
RUNSPACE=$(dirname $(realpath "$BASH_SOURCE"))
MAC_ROOT_DOWANLOAD=~/Mac-Root/Users/jackey/Downloads/
WORKSPACE=~/My_Project/dreame/clean/robot_-simulation-/workspace/
PACKAGE_LOG_NAME=$1

if [[ $PACKAGE_LOG_NAME == "" ]]; then
  echo "\tUsage: make_mcap.sh <package log name> \n\t 打包日志应该放到主系统的Downloads下面"
  exit
fi

echo "Start work at path: " $RUNSPACE
echo "Package log abs path: " $MAC_ROOT_DOWANLOAD/$PACKAGE_LOG_NAME

cd $WORKSPACE/recorder/build
rm -rf fuck
mkdir -p fuck
cp $MAC_ROOT_DOWANLOAD/$PACKAGE_LOG_NAME fuck/

# 先创建docker
$RUNSPACE/log_in_docker.sh not_run_shell

# docker cp 无法overwrite 文件，所以必须先手动删除一下。。。就是这么tmd愚蠢
docker exec -it xxx sh -c 'rm -rf /tmp/make_mcap_in_docker.sh'
docker cp $RUNSPACE/mcap_tools/make_mcap_in_docker.sh "xxx:/tmp/make_mcap_in_docker.sh"
docker exec -it -u $USER -e USER xxx zsh /tmp/make_mcap_in_docker.sh $PACKAGE_LOG_NAME

du -h $WORKSPACE/recorder/build/data.mcap
rm -rf $MAC_ROOT_DOWANLOAD/data.mcap
cp $WORKSPACE/recorder/build/data.mcap $MAC_ROOT_DOWANLOAD/
