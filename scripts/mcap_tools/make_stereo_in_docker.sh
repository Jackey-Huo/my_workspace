#!/usr/bin/env zsh

source ~/.zshrc

PACKAGE_LOG_NAME=$1


cd_workspace
cd recorder/build

case "$PACKAGE_LOG_NAME" in
  *.pack.tbz2)
    echo "Extracting '$PACKAGE_LOG_NAME'... with tar -xf"
    tar -xf fuck/$PACKAGE_LOG_NAME -C fuck/
    ;;
  *.tar.gz)
    echo "Extracting '$PACKAGE_LOG_NAME'... with tar -xvzf"
    tar -xvzf fuck/$PACKAGE_LOG_NAME -C fuck/
    ;;
  *.zip)
    echo "Extracting '$PACKAGE_LOG_NAME'... with unzip"
    unzip fuck/$PACKAGE_LOG_NAME -d fuck/
    ;;
  *.rar)
    echo "Extracting '$PACKAGE_LOG_NAME'... with unrar"
    unrar x fuck/$PACKAGE_LOG_NAME fuck/
    ;;
  *)
    echo "FUCK!!!!!!!!!!!!!!! Unknown file format '$PACKAGE_LOG_NAME'... donot extract!"
    rm -rf fuck/*
    ;;
esac

# find all data.bin and expand the stereo data
find fuck/ -type f -name "data.bin" -exec sh -c \
  'echo "Found: {}, start expand stereo_image_gray" && ./dmreader-1.5.0-linux-x86_64/dmreader x --topic stereo_image_gray --output . {}' ';'
