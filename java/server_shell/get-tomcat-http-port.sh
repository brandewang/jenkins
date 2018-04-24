#!/bin/bash
if [[ -z $2 ]];then
    echo "参数错误!"
    exit 1
fi
project=$1
tomcat_path=$2
server_file=${tomcat_path}/tomcat-${project}/conf/server.xml
port_path="/data/ports/"
port_file=${port_path}${project}
if [[ ! -d ${port_path} ]];then
    mkdir -p ${port_path}
fi
if [[ -f ${server_file} ]];then
    port=$(cat ${server_file}|grep HTTP |grep -Po [0-9]\{4,5\}|head -n1)
    if [[ ${port} != "" ]];then
        echo ${port}
        echo ${port} > ${port_file}
    else
       if [[ -f ${port_file} ]];then
           cat ${port_file}
       fi
    fi
fi
