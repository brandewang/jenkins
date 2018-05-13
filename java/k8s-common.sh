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

if [[ -z ${NUM} ]];then
    num=1
fi

if [[ -z ${CPU} ]];then
    requests_cpu=300
    limits_cpu=4000
fi
