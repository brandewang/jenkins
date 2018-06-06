#!/usr/bin/python
#coding:UTF-8
import ansible_parser
import sys,re


#报表
print '-------------report----------------'
print("%-25s\t%-20s\t%-10s\t%-20s" %('app','ip','port','type'))
#print('\n')
for app, var in ansible_parser.app_dicts.items():
    try:
        if len(var['ip']) > 1:
            i = 0
            while i < len(var['ip']):
                print("%-25s\t%-20s\t%-10s\t%-20s" %(app,var['ip'][i],var.get('port', 'null'),var.get('type', 'null')))
                i = i + 1
            continue
    except:
        pass
    print("%-25s\t%-20s\t%-10s\t%-20s" %(app,var.get('ip', ['null'])[0],var.get('port', 'null'),var.get('type', 'null')))

    
