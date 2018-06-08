#!/bin/bash
service=$2

case $1 in 
restart)
    echo test restart
    ;;
all_service_check)
    bash  /home/www/jenkins/scripts/ansible/all_service_check.sh
    ;;
esac
