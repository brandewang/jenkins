#!/bin/bash
if [[ -z $1 ]];then
    echo "参数错误!"
    exit 1
fi
service_name=$1
log_path=$2
log_file=${log_path}${service_name}"/start.log"
if [[ -f ${log_file} ]];then
    cat ${log_file} | grep "Tomcat initialized" |grep -Po [0-9]\{4,5\} |tail -n1
else
    echo "no file"
fi
