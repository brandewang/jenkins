#!/bin/bash
harbor_domain="k8s-harbor.test.fruitday.com"
harbor_repo="fruitday"
k8s_project_path=${project_path}"/k8s/"
k8s_project_backup_path=${JENKINS_HOME}/backup/k8s/${JOB_NAME}
k8s_backup_path=${k8s_project_backup_path}/${BUILD_NUMBER}/
namespace=$(echo ${JOB_NAME} | awk -F '/' '{print $1}')

rollback_path=${k8s_project_backup_path}/${rollback_version}

ln -s ${k8s_project_backup_path} ${project_path}/backup
echo k8s_project_path ${k8s_project_path}
mkdir -p ${k8s_project_path}

if [[ ! -d ${k8s_backup_path} ]];then
     mkdir -p ${k8s_backup_path}
fi

# 副本数量
if [[ -z ${REPLICAS_NUM} ]];then
    replicas_num=1
else
    replicas_num=${REPLICAS_NUM}
fi

if [[ -z ${CPU} ]];then
    requests_cpu=300
    limits_cpu=4000
fi

((limits_mem=${usage_mem}*2))
((xmx_mem=${usage_mem}+128))


# 这一块以后会去除
if [[ ${CHOICE_SUBITEM} == "" ]];then
    pro_project_config_path=${pro_config_path}${project}
    pg_project_config_path=${pg_config_path}${project}
else 
    pro_project_config_path=${pro_config_path}${project}/${CHOICE_SUBITEM}
    pg_project_config_path=${pg_config_path}${project}/${CHOICE_SUBITEM}
fi
