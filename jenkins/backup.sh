#!/bin/bash
# 备份jenkins
set -x
delete_day=7
jenkins_backup_path=${JENKINS_HOME}/backup/jenkins/
jenkins_backup_exclude_file=${JENKINS_HOME}/scripts/jenkins/exclude.file

if [[ ! -d ${jenkins_backup_path} ]];then
    mkdir -p ${jenkins_backup_path}
fi
date=`date +%Y%m%d-%H`
tar_gz_name="jenkins.tar.gz-"${date}
tar -zcf ${tar_gz_name} ${JENKINS_HOME}/* --exclude-from=${jenkins_backup_exclude_file}
echo "backup jenkins to "${tar_gz_name}

if [[ $? -eq 0 ]];then
    sudo chattr -i ${jenkins_backup_path}
    mv ${tar_gz_name} ${jenkins_backup_path}
fi
if [[ $? -eq 0 ]];then
    find ${jenkins_backup_path}  -mtime +${delete_day}|xargs rm
    ls -al ${jenkins_backup_path}
fi
sudo chattr +i ${jenkins_backup_path}
