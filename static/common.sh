#!/bin/bash
# 公共资源
if [[ ${JOB_NAME} =~ ^pro- ]];then
    hosts_file=${PRO_ANSIBLE_FILE}
    user="ec2-user"
else
    hosts_file=${PG_ANSIBLE_FILE}
    user="www"
fi

hosts='static'
group=${user}
project=$(echo ${JOB_NAME} | awk -F '/' '{print $NF}')

if [[ ${SRC_PATH} == "" ]];then
    src_path=`pwd`"/"
else
    src_path=`pwd`"/"${SRC_PATH}
fi
# 同步到远程目录
dest_path=${REMOTE_STATIC_PATH}${project}
