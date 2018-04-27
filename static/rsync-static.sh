#!/bin/bash
# 同步静态资源文件
source ${JENKINS_STATIC_SHELL_PATH}/common.sh
if [[ -d ${src_path} ]];then
    echo ansible-playbook -i ${hosts_file} --extra-vars "hosts=${hosts} src=${src_path} dest=${dest_path} owner=${user} group=${group}" rsync-static.yaml
    ansible-playbook -i ${hosts_file} --extra-vars "hosts=${hosts} src=${src_path} dest=${dest_path} owner=${user} group=${group}" ${JENKINS_STATIC_SHELL_PATH}/rsync-static.yaml
else
    echo ${src_path}不存在，请联系管理员!
    exit 1
fi
