#!/bin/bash
if [[ -z $2 ]];then
    echo "参数错误!"
    exit 1
fi
date=`date +%Y-%m-%d-%H%M`
project=$1
tomcat_path=$2
tomcat_bin_path=${tomcat_path}/tomcat-${project}/bin/
tomcat_logs_path=${tomcat_path}/tomcat-${project}/logs/
tomcat_work_path=${tomcat_path}/tomcat-${project}/work/
if [[ -d ${tomcat_work_path} ]];then
    rm -rf ${tomcat_work_path}*
fi
cd ${tomcat_bin_path}
if [[ -f ${tomcat_logs_path}catalina.out ]];then
    mv ${tomcat_logs_path}catalina.out  ${tomcat_logs_path}catalina.out-${date}
fi
bash startup.sh
echo `hostname` "start " ${project} " tomcat......"
ps aux|grep "/tomcat-${project}/" |grep -v "grep"
