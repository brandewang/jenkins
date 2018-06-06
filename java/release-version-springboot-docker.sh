#!/bin/bash
set -x
# 发布代码
source ${JENKINS_JAVA_SHELL_PATH}/common.sh
source ${JENKINS_JAVA_SHELL_PATH}/common-function.sh
source ${JENKINS_JAVA_SHELL_PATH}/k8s-common.sh
source ${JENKINS_JAVA_SHELL_PATH}/k8s-common-function.sh

if [[ ${to_rollback} == "" ]];then
    desc=${GIT_COMMIT}
    # 检测本次编译后，是否有超出预期效果的情况
    check_package_springboot
    src_package=${package}
    if [[ -z ${src_package} ]];then
        echo "src_package not found!";
        exit 1
    fi
    image_name=${harbor_domain}/${harbor_repo}/${service_name}:${GIT_COMMIT}
    check_image
    check_namespace 
    replace_k8s_yaml
    k8s_conf_backup
    apply_yaml
else
    desc="rollback to "${rollback_version}
    replace_k8s_yaml
    apply_yaml
fi

push_jenkins_desc
