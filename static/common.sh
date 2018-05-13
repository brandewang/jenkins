#!/bin/bash
# 公共资源
if [[ ${JOB_NAME} =~ ^pro- ]];then
    user="ec2-user"
    hosts_file=${JENKINS_HOME}/ansible/hosts
else
    user="www"
    hosts_file=${JENKINS_HOME}/ansible/pg-hsts
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
dest_path="/data/static/"${project}
