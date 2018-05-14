#!/bin/bash
set -x
# 发布代码
source ${JENKINS_JAVA_SHELL_PATH}/common.sh
source ${JENKINS_JAVA_SHELL_PATH}/k8s-common.sh
function check_package_springboot {
    cd ${project_path}
    package=$(find . -name *.war | awk -F '.war' '{print $1}')
    package_num=$(echo ${package} |wc -l)
    if [[ ${package_num} -ne 1 ]];then
        echo "package num is error! ${package}"
        exit 1
    fi
}

function check_image {
    harbor_http_code=$(curl -I -k  -o /dev/null -s -w %{http_code} -X GET "https://${harbor_domain}/api/repositories/${harbor_repo}/${service_name}/tags/${GIT_COMMIT}")
    if [[ ${harbor_http_code} -ne "200" ]];then
        echo "build image ..."
        build_image
    else
        echo ${GIT_COMMIT} "镜像已存在，不再重新构建!"
    fi
}

function build_image {
    cp ${JENKINS_JAVA_SHELL_PATH}dockerfiles/${CONTAINER_TYPE} ${project_path}/Dockerfile
    docker build --build-arg path=${src_package} -t ${image_name} .
    docker push ${image_name} 
}

function check_namespace {
    /usr/local/bin/kubectl get namespace ${namespace}
    if [[ $? -ne 0 ]];then
        /usr/local/bin/kubectl create namespace ${namespace}
    fi
}

function k8s_conf_backup {
    cp -r ${k8s_project_path}/* ${k8s_backup_path}
}

function replace_k8s_yaml {
    cp ${JENKINS_JAVA_SHELL_PATH}k8s/demo/${CONTAINER_TYPE}-* ${k8s_project_path}/
    cd ${k8s_project_path}
    files=$(ls)
    escape_image_name=$(echo ${image_name} |sed 's/\//\\\//g')
    escape_check_uri=$(echo ${check_uri} |sed 's/\//\\\//g')
    for file in ${files}
    do 
        sed -i "s/{APPNAME}/${service_name}/g" ${k8s_project_path}/${file}
        sed -i "s/{CHECK_URI}/${escape_check_uri}/g" ${k8s_project_path}/${file}
        sed -i "s/{IMAGE_NAME}/${escape_image_name}/g" ${k8s_project_path}/${file}
        sed -i "s/{NAMESPACE}/${namespace}/g" ${k8s_project_path}/${file}
        sed -i "s/{LIMITS_CPU}/${limits_cpu}/g" ${k8s_project_path}/${file}
        sed -i "s/{LIMITS_MEM}/${limits_mem}/g" ${k8s_project_path}/${file}
        sed -i "s/{NUM}/${num}/g" ${k8s_project_path}/${file}
        sed -i "s/{REQUESTS_CPU}/${requests_cpu}/g" ${k8s_project_path}/${file}
        sed -i "s/{REQUESTS_MEM}/${usage_mem}/g" ${k8s_project_path}/${file}
        sed -i "s/{XMX_MEM}/${xmx_mem}/g" ${k8s_project_path}/${file}
    done
}

function apply_yaml {
    /usr/local/bin/kubectl apply -f ${k8s_project_path}
    if [[ $? -ne 0 ]];then
        echo 'error'
        exit 1
    fi
}

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

# jenkins打标签
curl -n -X POST -d "description=${desc}" "${BUILD_URL}/submitDescription"
