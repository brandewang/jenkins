#!/bin/bash
if [[ -z $1 ]];then
    echo "参数错误!"
    exit 1
fi
project=$1
port=`ps -ef|grep "/tomcat-${project}/"|grep -v "grep"|awk '{print $2}'`
if [[ ${port} != "" ]];then
    kill ${port}
    sleep 1
    kill -9 ${port}
fi
