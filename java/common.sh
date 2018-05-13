#!/bin/bash # 公共资源
if [[ ${JOB_NAME} =~ ^pro- ]];then
    user="ec2-user"
    hosts_file=${JENKINS_HOME}/ansible/hosts
    config_path=${JENKINS_HOME}/workspace/ops-common/pro-config/
    backup='yes'
else
    user="www"
    hosts_file=${JENKINS_HOME}/ansible/pg-hosts
    config_path=${JENKINS_HOME}/workspace/ops-common/pg-config/
    backup='no'
fi
remote_shell_path="/home/www/publish-shell/"
remote_springboot_project_path="/data/jar/"
remote_tomcat_path="/data/tomcat/"
remote_java_logs="/data/logs/all-tomcat-logs/"
lock_path=${JENKINS_JAVA_SHELL_PATH}"/lock/${JOB_NAME}/"
if [[ ! -d ${lock_path} ]];then
    mkdir -p ${lock_path}
fi
project=$(echo ${JOB_NAME} | awk -F '/' '{print $NF}')
if [[ -z ${PACKAGE_SUFFIX} ]];then
    package_suffix="jar"
else
    package_suffix=${PACKAGE_SUFFIX}
fi
# 配置文件目录
if [[ ${CHOICE_SUBITEM} == "" ]];then
    project_config_path=${config_path}${project}
    project_path=${JENKINS_HOME}/workspace/${JOB_NAME}
    project_backup_path=${JENKINS_HOME}/backup/code/${JOB_NAME}
    remote_tomcat_project_path=${remote_tomcat_path}"tomcat-"${project}/webapps/ROOT/
    service_name=${project}
    package_name=${project}"."${package_suffix}
    remote_ips=`python ${JENKINS_JAVA_SHELL_PATH}/get-pool-info.py ${hosts_file} ${project}`
    lock_file=${lock_path}${project}
else 
    project_config_path=${config_path}${project}/${CHOICE_SUBITEM}
    project_path=${JENKINS_HOME}/workspace/${JOB_NAME}/${CHOICE_SUBITEM}
    project_backup_path=${JENKINS_HOME}/backup/code/${JOB_NAME}/${CHOICE_SUBITEM}
    if [[ ${CHOICE_SUBITEM} == "hr-wx" ]];then
        remote_tomcat_project_path=${remote_tomcat_path}"tomcat-"${CHOICE_SUBITEM}/webapps/${CHOICE_SUBITEM}/
    else
        remote_tomcat_project_path=${remote_tomcat_path}"tomcat-"${CHOICE_SUBITEM}/webapps/ROOT/
    fi
    service_name=${CHOICE_SUBITEM}
    package_name=${service_name}"."${package_suffix}
    remote_ips=`python ${JENKINS_JAVA_SHELL_PATH}/get-pool-info.py ${hosts_file} ${CHOICE_SUBITEM}`
    lock_file=${lock_path}${project}${CHOICE_SUBITEM}
fi

if [[ ! -z ${ROLLBACK_VERSION} ]];then
    rollback_version=$(echo ${ROLLBACK_VERSION}|awk -F '/' '{print $(NF-1)}')
    rollback_path=${project_backup_path}/${rollback_version}
fi
backup_path=${project_backup_path}/${BUILD_NUMBER}/
if [[ ${backup} == "yes" ]];then
    ln -s ${project_backup_path} ${project_path}/backup
fi
# 项目路径
cd ${project_path}
if [[ $? -ne 0 ]];then
    echo ${project_path}"不存在！"
    exit 1
fi

# 需要覆盖的配置文件目录
resources_path=${project_path}/src/main/resources/
scheme="http://"
if [[ -z ${CHECK_URI} ]];then
    check_uri="/index.jsp"
else
    check_uri=${CHECK_URI}
fi
check_time=120

# springboot 项目
if [[ -z ${USAGE_MEM} ]];then
    usage_mem="512"
else
    if [[ ${USAGE_MEM} -gt 0 ]] 2>/dev/null;then
        usage_mem=${USAGE_MEM}
    else
        echo ${USAGE_MEM} is not int !
        exit
    fi
fi



