#!/usr/bin/env zsh

PACKAGE_LOG_NAME=$1


source ~/.zshrc

cd_workspace
cd recorder/build

tar -xvzf fuck/$PACKAGE_LOG_NAME -C fuck/
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

./build/apps/dmreader convert $data_bin_paths -output=data.mcap

