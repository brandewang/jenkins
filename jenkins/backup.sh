#!/bin/bash
# 备份jenkins整个目录
jenkins_path="/home/www/jenkins/"
jenkins_backup_path="/data/jenkins-backup/"
if [[ ! -d ${jenkins_backup_path} ]];then
    mkdir -p ${jenkins_backup_path}
fi
date=`date +%Y%m%d-%H`
tar_gz_name="jenkins.tar.gz-"${date}
tar -zcf ${tar_gz_name} ${jenkins_path}* --exclude=workspace/* --exclude=modules/*
if [[ $? -eq 0 ]];then
    mv ${tar_gz_name} ${jenkins_backup_path}
fi
echo ${date}
ls -al ${jenkins_backup_path}
