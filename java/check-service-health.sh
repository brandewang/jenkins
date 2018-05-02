#!/bin/bash
# 验证服务状态是否异常
sleep 10
# 验证端口是否已启动
function check_port_status(){
    nmap ${remote_ip} -p ${http_port} | grep "open" > /dev/null
    if [[ $? -eq 0 ]];then
        http_port_status=0
    else
        http_port_status=1
    fi
}

function check_service_status(){
    url=${scheme}${remote_ip}":"${http_port}${check_uri}
    http_code=$(curl -I -k --connect-timeout ${check_time} -m ${check_time} -o /dev/null -s -w %{http_code} "${url}")
    if [[ $? -ne 0 || ${http_code} == "404" ]];then
        service_status="error" 
    else
        service_status="ok" 
    fi
}

# 获取启动端口
http_port=$(ssh ${user}@${remote_ip} "bash ${REMOTE_SHELL_PATH}${shell_name} ${service_name} ${remote_path}")
if [[ -z ${http_port} ]];then
    echo "端口未获取到，请联系管理员！"
    service_status="error"
else
    check_port_status
    i=1
    while (( ${http_port_status} != 0 && i < 30 ));
    do
        check_port_status
        ((i++))
        sleep 1
    done
    if [[ ${http_port_status} == 1 ]];then
        echo ${http_port}"端口不通，请联系管理员！"
        service_status="error"
    else
        service_status="ok"
        if [[ ${check_uri} != 'nocheck' ]];then
            check_service_status
        fi
    fi
fi
