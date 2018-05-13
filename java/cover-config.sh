#!/bin/bash
# 部分tomcat服务有web.xml概念，并且需要覆盖。
# 建议开发修复
# 覆盖配置文件
source ${JENKINS_JAVA_SHELL_PATH}common.sh
if [[ -d ${project_config_path} ]];then
    rsync -av ${project_config_path}/* ${resources_path} --exclude web.xml
    if [[ $? -ne 0 ]];then
        exit 1
    fi

    webxml=$(find ${project_config_path} -name web.xml)
    if [[ ${webxml} != "" ]];then
        rsync -av ${webxml} ${resources_path}../webapp/WEB-INF/web.xml
        if [[ $? -ne 0 ]];then
            exit 1
        fi
    fi 
fi

cd ${resources_path}
echo '-----------------------------------------------------------------'
git status
git lg -n4
echo '-----------------------------------------------------------------'
