#!/bin/bash
# 公共资源
if [[ ${JOB_NAME} =~ ^pro- ]];then
    project=${JOB_NAME}
    user=${PRO_USER}
    hosts=${PRO_ANSIBLE_FILE}
    config_path=${PRO_CONFIG_PATH}
    # 需要归档
    backup='yes'
else
    user=${PG_USER}
    hosts=${PG_ANSIBLE_FILE}
    config_path=${PG_CONFIG_PATH}
    # 不需要归档
    backup='no'
fi
namespace=$(echo ${JOB_NAME} | awk -F '/' '{print $1}')
lock_path=${JENKINS_JAVA_SHELL_PATH}"/lock/${namespace}/"
if [[ ! -d ${lock_path} ]];then
    mkdir -p ${lock_path}
fi
project=$(echo ${JOB_NAME} | awk -F '/' '{print $NF}')
# 配置文件目录
if [[ ${CHOICE_SUBITEM} == "" ]];then
    project_config_path=${config_path}${project}
    project_path=${JENKINS_HOME}/workspace/${JOB_NAME}
    project_backup_path=${CODE_BACK_PATH}${project}
    remote_tomcat_project_path=${REMOTE_TOMCAT_PATH}"tomcat-"${project}/webapps/ROOT/
    service_name=${project}
    remote_ips=`python ${JENKINS_JAVA_SHELL_PATH}/get-pool-info.py ${hosts} ${project}`
    lock_file=${lock_path}${project}
else 
    project_config_path=${config_path}${project}/${CHOICE_SUBITEM}
    project_path=${JENKINS_HOME}/workspace/${JOB_NAME}/${CHOICE_SUBITEM}
    project_backup_path=${CODE_BACK_PATH}${JOB_NAME}/${CHOICE_SUBITEM}
    if [[ ${CHOICE_SUBITEM} == "hr-wx" ]];then
        remote_tomcat_project_path=${REMOTE_TOMCAT_PATH}"tomcat-"${CHOICE_SUBITEM}/webapps/${CHOICE_SUBITEM}/
    else
        remote_tomcat_project_path=${REMOTE_TOMCAT_PATH}"tomcat-"${CHOICE_SUBITEM}/webapps/ROOT/
    fi
    service_name=${CHOICE_SUBITEM}
    remote_ips=`python ${JENKINS_JAVA_SHELL_PATH}/get-pool-info.py ${hosts} ${CHOICE_SUBITEM}`
    lock_file=${lock_path}${project}${CHOICE_SUBITEM}
fi

rollback_version=$(echo ${ROLLBACK_VERSION}|awk -F '/' '{print $(NF-1)}')
rollback_path=${project_backup_path}/${rollback_version}
remote_springboot_project_path=${REMOTE_SPRINGBOOT_PATH}
backup_path=${project_backup_path}/${BUILD_NUMBER}/
# 项目路径
cd ${project_path}
if [[ $? -ne 0 ]];then
    echo ${project_path}"不存在！"
    exit 1
fi

# 需要覆盖的配置文件目录
resources_path=${project_path}/src/main/resources/
scheme="http://"
if [[ ${CHECK_URI} == "" ]];then
    check_uri="/index.jsp"
else
    check_uri=${CHECK_URI}
fi
check_time=120

# springboot 项目
if [[ ${USAGE_MEM} == "" ]];then
    usage_mem="512"
else
    if [[ ${USAGE_MEM} -gt 0 ]] 2>/dev/null;then
        usage_mem=${USAGE_MEM}
    else
        echo ${USAGE_MEM} is not int !
        exit
    fi
fi

