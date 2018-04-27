#!/bin/bash
# 发布的版本异常，自动回退
# 回退代码
source ${JENKINS_JAVA_SHELL_PATH}common.sh

if [[ -z $1 ]];then
    echo  '参数错误！use tomcat or springboot'
    exit 1
fi
service_container=$1
remote_ips=$2
to_rollback="rollback"

# 获取最新的备份目录
if [[ ${remote_ips} != "" ]];then
    # 获取最近时间的一个版本号
    rollback_version=$(ls -tr ${project_backup_path} | tail -n 1)
    rollback_path=${project_backup_path}/${rollback_version}
fi

# 保险起见，判断备份目录存在并且不为空
if [[ -d ${rollback_path} ]];then
    if [ "`ls -A ${rollback_path}`" == "" ]; then
        echo ${rollback_path}"备份目录存在，但内容为空，请联系管理员！"
        exit 1
    else
        echo "准备rollback"
        source ${JENKINS_JAVA_SHELL_PATH}/release-version-${service_container}.sh ${service_container} ${remote_ips}
    fi 
else
    echo ${rollback_path}"备份目录不存在，请联系管理员！"
    if [ -f ${lock_file} ];then
        rm ${lock_file}
    fi
    exit 1
fi
