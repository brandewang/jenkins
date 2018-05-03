#!/bin/bash
set -x
# 发布代码
source ${JENKINS_JAVA_SHELL_PATH}/common.sh

shell_name='get-tomcat-http-port.sh'
remote_path=${REMOTE_TOMCAT_PATH}
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

function check_package_tomcat {
    cd ${project_path}
    package=$(find . -name *.war | awk -F '.war' '{print $1}')
    package_num=$(echo ${package} |wc -l)
    if [[ ${package_num} -ne 1 ]];then
        echo "package num is error! ${package}"
#        rm ${lock_file}
        exit 1
    fi
}

function project_backup {
    if [[ ${backup} == "yes" ]];then
        # libsapjco3.so 用途为调用SAP，部分项目会使用
        if [[ ${LIBSAP} == "true" ]];then
            cp ${JENKINS_JAVA_SHELL_PATH}/so/libsapjco3.so ${package}/WEB-INF/lib/
        fi
        
        mkdir -p ${backup_path}
        rsync -a ${package}/* ${backup_path}
    fi
}

function restart_service {
    ssh ${user}@${remote_ip} "bash ${REMOTE_SHELL_PATH}"shutdown-tomcat.sh" ${service_name}"
    rsync -a ${src_package}/* ${user}@${remote_ip}:${remote_tomcat_project_path} --delete-after
    ssh ${user}@${remote_ip} "bash ${REMOTE_SHELL_PATH}"startup-tomcat.sh" ${service_name} ${remote_path}"
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
    # 检测本次编译后，是否有超出预期效果的情况
    check_package_tomcat
    src_package=${package}
    if [[ -z ${src_package} ]];then
        echo "src_package not found!";
        exit 1
    fi
    # 归档代码
    project_backup
else
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
