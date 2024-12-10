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

find fuck/ -name "data.bin"

# 使用find命令搜索文件，输出文件相对路径
# 并使用tr命令替换换行符为逗号
data_bin_paths=$(find "fuck/" -name 'data.bin' -printf 'fuck/%P,')
# 如果找到的字符串不为空，那么移除最后一个逗号
if [ -n "$data_bin_paths" ]; then
	data_bin_paths=${data_bin_paths%,}
fi
# 打印最终的路径字符串
echo "$data_bin_paths"

./dmreader-1.5.0-linux-x86_64/dmreader convert $data_bin_paths -output=data.mcap
