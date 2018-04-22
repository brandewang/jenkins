#!/usr/bin/python
#coding:UTF-8

import os, re, sys

lock=True
ip = ''
group_list = []
hosts_info = {}
hosts_file =  sys.argv[1] 
def main():
    with open(hosts_file) as hosts:
        for i in hosts:
            global group
            global ip
            if i.startswith('[') and "children" not in i:
                group = i.strip('\n').strip('[').strip(']')
                get_group()
            else:
                ip = i.split(' ')[0].strip('\n')
                if re.match(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$", ip):
                    hosts_info.setdefault(group, []).append(ip)
        get_group_ip()

    return hosts_info


def get_group( todo = 'add'):
    if todo == 'add':
        group_list.append(group)
    else:
        group_list.sort()
        for i in range(len(group_list)):
            print group_list[i]
    return group_list

def get_group_ip():
    flag = True
    pool_ips = ''
    try:
        input_name =  sys.argv[2] 
        list = hosts_info[input_name]
        for i in range(len(list)):
            if i == len(list)-1:
                pool_ips += list[i]
            else:
                pool_ips += list[i] + " "
        flag = False
        print pool_ips
    except:
        print ""
    return input_name

main()
