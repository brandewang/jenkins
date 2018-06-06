#!/bin/bash
# 发布代码
set -x
source ${JENKINS_JAVA_SHELL_PATH}/common.sh
source ${JENKINS_JAVA_SHELL_PATH}/common-function.sh

shell_name='get-tomcat-http-port.sh'
remote_path=${remote_tomcat_path}
if [[ ! -z $2 ]];then
    remote_ips=$2
fi
## 判断是否有人在使用
#if [ -f ${lock_file} ];then
#    echo "Version is releasing,Please wait a moment! "
#    exit 1
#else
#    touch ${lock_file}
#fi

function project_backup {
    if [[ ${backup} == "yes" ]];then
        mkdir -p ${backup_path}
        rsync -a ${package}/* ${backup_path}
    fi
}

function restart_service {
    ssh ${user}@${remote_ip} "bash ${remote_shell_path}"shutdown-tomcat.sh" ${service_name}"
    rsync -a ${src_package}/* ${user}@${remote_ip}:${remote_tomcat_project_path} --delete-after
    sleep 10
    ssh ${user}@${remote_ip} "bash ${remote_shell_path}"startup-tomcat.sh" ${service_name} ${remote_path}"
    if [[ ${service_status} == "" && ${to_rollback} == "" ]];then
        source ${JENKINS_JAVA_SHELL_PATH}/check-service-health.sh
        if [[ ${service_status} == "error" ]];then
#            rm ${lock_file}
            if [[ ${backup} == "yes" ]];then
                if [[ -d ${backup_path} ]];then
                    rm -rf ${backup_path}
                fi
                # 默认恢复至上一个正确的版本（ROLLBACK_VERSION）
                source ${JENKINS_JAVA_SHELL_PATH}/rollback.sh "tomcat" "${remote_ip}"
                echo 本次版本发布异常，已回退至版本: ${rollback_version}
                exit 1
            else
               echo "本次发布异常，请确认!"
               echo ${url} ${http_code}
               exit 1
            fi
        fi
    fi
}

if [[ ${to_rollback} == "" ]];then
    desc=${GIT_COMMIT}
    # 检测本次编译后，是否有超出预期效果的情况
    check_package_tomcat
    src_package=${package}
    if [[ -z ${src_package} ]];then
        echo "src_package not found!";
        exit 1
    fi
    cp_libsap
    # 归档代码
    project_backup
else
    desc="rollback to "${rollback_version}
    src_package=${rollback_path}
fi

for remote_ip in ${remote_ips}
do
    restart_service
done

# 回退
if [[ ${to_rollback} != "" ]];then
    echo '回退成功，本次构建结束！'
    echo 'jenkins报错不用管！'
    exit 1
fi
#rm ${lock_file}

push_jenkins_desc
