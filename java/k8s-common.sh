#!/bin/bash
harbor_domain="k8s-harbor.test.fruitday.com"
harbor_repo="fruitday"
k8s_path="/data/kubernetes/"
namespace=$(echo ${JOB_NAME} | awk -F '/' '{print $1}')

if [[ ${CHOICE_SUBITEM} == "" ]];then
    k8s_project_path=${k8s_path}${namespace}/${project}
else
    k8s_project_path=${k8s_path}${namespace}/${project}/${CHOICE_SUBITEM}
fi

if [[ ! -d ${k8s_project_path} ]];then
     mkdir -p ${k8s_project_path}
fi

if [[ -z ${NUM} ]];then
    num=1
fi

if [[ -z ${CPU} ]];then
    requests_cpu=300
    limits_cpu=4000
fi
