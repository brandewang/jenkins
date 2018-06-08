#!/bin/bash
tmp_file='/tmp/check_list'
result='/tmp/all_service_check.log'
date > $result
python /home/www/jenkins/scripts/ansible/app_getinfo.py gen_check_list > $tmp_file

function check_service_status {
    if [[ ${se_which} == "auth" ||  ${se_which} == "sap-data" ]];then
        url="https://${ip}:${port}${check_url}"
    else
        url="http://${ip}:${port}${check_url}"
    fi
    http_code=`curl -I -k --connect-timeout 10 -m 10 -o /dev/null -s -w %{http_code} "${url}"`
    if [[ $? -ne 0 ]];then
        echo ${se_which} ${url} is not start! >> ${result}
    elif [[ ${http_code} == "404" ]];then
        echo ${se_which} ${url} is 404! >> ${result}
    else
        echo ${se_which} is ok >> ${result}
    fi
}



while read line
do
    line=($line)
    which=${line[0]}
    se_which=${line[1]}
    type=${line[2]}
    port=${line[3]}
    check_url=${line[4]}
    ips=`python /home/www/jenkins/scripts/ansible/app_getinfo.py $se_which get_ip`
    if [[ ${ips} =~ "192.168" ]];then
        lenth=`echo $ips|awk '{print NF}'`
        if [[ $lenth -gt 1 ]];then
            for ip in $ips
            do
                check_service_status
            done
        else
            ip=${ips}
            check_service_status
        fi
    fi
done < $tmp_file
echo '-------------------------------------------'
cat $result
echo '-------------------------------------------'
