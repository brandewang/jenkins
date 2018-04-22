#!/bin/bash
if [[ -z $1 ]];then
    echo "参数错误!"
    exit 1
fi
package_name=$1
pid=$(ps aux | grep -v grep |grep "/data/jar/"${package_name} | awk '{print $2}')
if [[ ${pid} != "" ]];then
    kill ${pid}
    sleep 1
    kill -9 ${pid}
fi
