#!/usr/bin/env bash

# This script is used to prepare the data for slam data
# 1. unpack the compressed file
# 2. expand data.bin to stereo_gray_image, and put it into ~/Slam_Replay folder
# 3. find the most large slamdata and put it into ~/Slam_Replay folder

# 同步各类设置
RUNSPACE=$(dirname $(realpath "$BASH_SOURCE"))
WORKSPACE=~/My_Project/dreame/clean/robot_-simulation-/workspace/
SLAM_REPLAY_DIR=~/Slam_Replay
SLAM_REPLAY_STEREO_IMG_DIR=~/Slam_Replay/stereo_image_gray
PACKAGE_LOG_PATH=$1
PACKAGE_LOG_NAME=$(basename $PACKAGE_LOG_PATH)

if [[ $PACKAGE_LOG_PATH == "" ]]; then
  echo "\tUsage: prepare_slamdata.sh <package log name> \n"
  exit
fi

echo "Start work at path: " $RUNSPACE
echo "Package log abs path: " $PACKAGE_LOG_PATH " name: " $PACKAGE_LOG_NAME

# 1. unpack the compressed file
# 2. expand data.bin to stereo_gray_image, and put it into ~/Slam_Replay folder
cd $WORKSPACE/recorder/build
rm -rf fuck
rm -rf stereo_image_gray
mkdir -p fuck
mkdir -p stereo_image_gray
cp $PACKAGE_LOG_PATH fuck/

# 先创建docker
$RUNSPACE/log_in_docker.sh not_run_shell

# docker cp 无法overwrite 文件，所以必须先手动删除一下。。。就是这么tmd愚蠢
# extract the compress file, and expand stereo_gray_image
docker exec -it xxx sh -c 'rm -rf /tmp/make_stereo_in_docker.sh'
docker cp $RUNSPACE/mcap_tools/make_stereo_in_docker.sh "xxx:/tmp/make_stereo_in_docker.sh"
docker exec -it -u $USER -e USER xxx zsh /tmp/make_stereo_in_docker.sh $PACKAGE_LOG_NAME

rm -rf $SLAM_REPLAY_STEREO_IMG_DIR
mkdir -p $SLAM_REPLAY_STEREO_IMG_DIR
mv $WORKSPACE/recorder/build/stereo_image_gray/* $SLAM_REPLAY_STEREO_IMG_DIR

# 3. find the most large slamdata and put it into ~/Slam_Replay folder
cd $SLAM_REPLAY_DIR
echo "Remove old slamdata and calib file"
rm -rf ./*.slamdata
# remove old calib file, to avoid use wrong file
rm -rf ./lds_config.json
rm -rf ./calibration_result_stereo.json

echo "Copy calib file and slamdata to Slam_Replay"
# move right calib file
find $WORKSPACE/recorder/build/fuck -type f -name "lds_config.json" -exec sh -c 'cp {} .' ';'
find $WORKSPACE/recorder/build/fuck -type f -name "lds_config.json" -exec sh -c 'cp {} .' ';'
# move slamdata bigger than 5MB
find $WORKSPACE/recorder/build/fuck -type f -name "*.slamdata" -size +5M -exec sh -c 'cp {} .' ';'

echo "Delete useless trash"
# finally, remove uncompress trash
cd $WORKSPACE/recorder/build
rm -rf fuck
rm -rf stereo_image_gray
