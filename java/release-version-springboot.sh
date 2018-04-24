#!/bin/bash
set -x
# 发布代码
source ${JENKINS_JAVA_SHELL_PATH}/common.sh

shell_name='get-springboot-http-port.sh'
remote_path=${REMOTE_JAVA_LOGS}
if [[ ! -z $2 ]];then
    remote_ips=$2
fi
# 判断是否有人在使用
if [ -f ${lock_file} ];then
    echo "Version is releasing,Please wait a moment! "
    exit 1
else
    touch ${lock_file}
fi

function check_package_springboot {
    cd ${project_path}
    package=$(find . -name ${project}"."${CHOICE_PACKAGE_SUFFIX})
    package_num=$(echo ${package} |wc -l)
    if [[ ${package_num} -ne 1 ]];then
        echo "package num is error! ${package}"
        rm ${lock_file}
        exit 1
    fi
}

function project_backup {
    if [[ ${backup} == "yes" ]];then
        mkdir -p ${backup_path}
        rsync -av ${package} ${backup_path}
    fi
}

function restart_service {
    ssh ${user}@${remote_ip} "bash ${REMOTE_SHELL_PATH}"shutdown-springboot.sh" ${service_name}"
    rsync -av ${src_package} ${user}@${remote_ip}:${remote_springboot_project_path}
    ssh ${user}@${remote_ip} "bash /etc/init.d/springboot restart ${service_name}"
    if [[ ${service_status} == "" ]];then
        source ${JENKINS_JAVA_SHELL_PATH}/check-service-health.sh
        if [[ ${service_status} == "error" ]];then
            rm ${lock_file}
            if [[ ${backup} == "yes" ]];then
                # 默认恢复至上一个正确的版本（ROLLBACK_VERSION）
                source ${JENKINS_JAVA_SHELL_PATH}/rollback.sh "springboot" "${remote_ip}"
                echo 本次版本发布异常，已回退至版本: ${rollback_version}
            else
               echo "本次发布异常，请确认!"
               exit 1
            fi
        fi
    fi
}

# 验证
check_package_springboot

# 归档代码
project_backup

if [[ ${to_rollback} == "" ]];then
    # 检测本次编译后，是否有超出预期效果的情况
    check_package_springboot
    src_package=${package}
    # 归档代码
    project_backup
else
    src_package=${rollback_path}
fi

for remote_ip in ${remote_ips}
do
    restart_service
done

rm ${lock_file}
