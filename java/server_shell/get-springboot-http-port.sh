#!/bin/bash
if [[ -z $2 ]];then
    echo "参数错误!"
    exit 1
fi
service_name=$1
log_path=$2
log_file=${log_path}${service_name}"/start.log"
port_path="/data/ports/"
port_file=${port_path}${service_name}
if [[ ! -d ${port_path} ]];then
    mkdir -p ${port_path}
fi
if [[ -f ${log_file} ]];then
    port=$(cat ${log_file} | grep "Tomcat initialized" |grep -Po [0-9]\{4,5\} |tail -n1)
    if [[ ${port} != "" ]];then
        echo ${port}
        echo ${port} > ${port_file}
    else
       if [[ -f ${port_file} ]];then
           cat ${port_file}
       fi
    fi
fi
