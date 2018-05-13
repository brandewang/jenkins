#!/bin/bash
# 备份jenkins
delete_day=5
jenkins_backup_path=${JENKINS_HOME}/jenkins_backup/
if [[ ! -d ${jenkins_backup_path} ]];then
    mkdir -p ${jenkins_backup_path}
fi
date=`date +%Y%m%d-%H`
tar_gz_name="jenkins.tar.gz-"${date}
tar -zcf ${tar_gz_name} ${JENKINS_HOME}/* --exclude=workspace/* --exclude=modules/* --exclude=code_backup/* --exclude=jenkins_backup/*
echo "backup jenkins to "${tar_gz_name}

if [[ $? -eq 0 ]];then
    mv ${tar_gz_name} ${jenkins_backup_path}
fi
if [[ $? -eq 0 ]];then
    #find ${jenkins_backup_path}  -mtime +${delete_day}|xargs rm
    find ${jenkins_backup_path}  -mtime +${delete_day}
    ls -al ${jenkins_backup_path}
fi
