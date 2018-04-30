#!/bin/bash
sleep 20
# 验证服务状态是否异常
http_port=$(ssh ${user}@${remote_ip} "bash ${REMOTE_SHELL_PATH}${shell_name} ${service_name} ${remote_path}")
if [[ -z ${http_port} ]];then
    echo "端口未获取到，请联系管理员！"
    service_status="noport"
else
    url=${scheme}${remote_ip}":"${http_port}${check_uri}
    http_code=$(curl -I -k --connect-timeout ${check_time} -m ${check_time} -o /dev/null -s -w %{http_code} "${url}")
    if [[ $? -ne 0 || ${http_code} == "404" ]];then
        service_status="error" 
    else
        service_status="ok" 
    fi
fi
