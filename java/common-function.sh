#!/bin/bash
function check_package_tomcat {
    cd ${project_path}
    package=$(find . -name *.war | awk -F '.war' '{print $1}')
    package_num=$(echo ${package} |wc -l)
    if [[ ${package_num} -ne 1 ]];then
        echo "package num is error! ${package}"
        exit 1
    fi
}

function check_package_springboot {
    cd ${project_path}
    package=$(find . -name ${package_name})
    package_num=$(echo ${package} |wc -l)
    if [[ ${package_num} -ne 1 ]];then
        echo "package num is error! ${package}"
        exit 1
    fi
}

# jenkins打标签
function push_jenkins_desc {
    curl -n -X POST -d "description=${desc}" "${BUILD_URL}/submitDescription"
}
