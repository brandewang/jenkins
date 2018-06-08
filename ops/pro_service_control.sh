#!/bin/bash
set -x

todo=$1
user='ec2-user'
shift 1
services=$@

function services_restart () {
    for service in $@
    do
        app=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_ip`
        if [[ $app =~ 'error' ]];then
            echo this app is not exists
            continue
        fi
        ips=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_ip`
        for ip in $ips
        do
           type=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_type`
           mem=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_mem`
           ssh -n ${user}@${ip} "bash /home/www/publish-shell/service-control.sh restart ${service} $type $mem"
        done
    done
}

function services_stop() {
    for service in $@
    do
        app=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_ip`
        if [[ $app =~ 'error' ]];then
            echo this app is not exists
            continue
        fi
        ips=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_ip`
        for ip in $ips
        do
           type=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $service get_type`
           ssh -n ${user}@${ip} "bash /home/www/publish-shell/service-control.sh stop ${service} $type"
        done
    done
}



case $todo in 
restart)
    services_restart $services
    ;;
stop)
    services_stop $services
    ;;
all_service_check)
    bash  /home/www/jenkins/scripts/ops/all_service_check.sh
    ;;
esac
