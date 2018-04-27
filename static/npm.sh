#!/bin/bash
# 同步静态资源文件
source ${JENKINS_STATIC_SHELL_PATH}/common.sh
if [[ -d ${src_path} ]];then
    cd ${src_path}
    npm install
    npm run build
else
    echo ${src_path}不存在，请联系管理员!
    exit 1
fi
