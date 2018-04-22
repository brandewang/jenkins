#!/bin/bash
if [[ -z $2 ]];then
    echo "参数错误!"
    exit 1
fi
project=$1
tomcat_path=$2
server_path=${tomcat_path}/tomcat-${project}/conf/server.xml
cat ${server_path}|grep HTTP |grep -Po [0-9]\{4,5\}|head -n1
