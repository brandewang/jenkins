#!/usr/bin/python
#coding:UTF-8
import sys
import ansible_parser


def main(app, todo, app_dicts):
    global result
    result = ''
    if app in app_dicts:
        if todo == 'get_app':
            result = app_dicts[app]
        elif todo == 'get_port':
            result = app_dicts[app].get('port', 'null')
        elif todo == 'get_type':
            result = app_dicts[app].get('type', 'null')
        elif todo == 'get_ip':
            result = ' '.join(app_dicts[app].get('ip', ['null']))
        else:
           print('error! worng args')
    else:
        print('error! this app is not exists')
    print result

def gen_check_list(app_dicts):
    for key,value in app_dicts.items():
        if value.has_key('check'):
            if value['type'] == 'springboot':
                type=1
            elif value['type'] == 'tomcat':
                type=0
            if value.has_key('uri'):
                uri=value['uri']
            else:
                uri='/index.jsp'
            print key,key,type,value['port'],uri


if __name__=="__main__":
    if sys.argv[1] == 'gen_check_list':
        gen_check_list(ansible_parser.app_dicts)
        exit(0)
    if len(sys.argv) != 3:
        print('Usage: host_parser.py app_name todo')
        exit(2)
    app, todo = sys.argv[1:3]
    main(app, todo, ansible_parser.app_dicts)
