#!/usr/bin/python
#coding:UTF-8
import sys,re,copy

result=''

def get_app_vars(vars_file):
    app_vars = {}
    with open(vars_file) as hosts:
        for i in hosts:
            if i.startswith('[') and re.search('vars', i):
                app = i.split(':')[0].strip('[')
                #print app
            elif i.startswith('[') and not re.search('vars', i):
                try:
                    del app
                except:
                    pass
            try:
                if not i.startswith('[') and app and re.search('=', i):
                   key = i.split('=')[0]
                   value = i.split('=')[1].strip('\n').strip('')
                   #print(key, value)
                   app_vars.setdefault(app, {}).setdefault(key, value)
            except:
                pass
    return app_vars


def get_app_hosts(hosts_file):
    regex=re.compile('hello|deploy|tomcat')
    app_hosts={}
    app=''
    with open(hosts_file) as hosts:
        for i in hosts:
            if i.startswith('[') and not regex.search(i):
                app = i.strip('\n').strip('[').strip(']')
                #print app
            elif i.startswith('[') and regex.search(i):
                try:
                    del app
                except:
                    pass
            try:
                #if re.match(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$", "292.168.1.1"):
                if re.match(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$", i) and app:
                    ip = i.strip('\n')
                    #print ip
                    app_hosts.setdefault(app, []).append(ip)
            except:
                pass
    return app_hosts

def get_app_dicts(app_vars, app_hosts):
    app_dicts = copy.deepcopy(app_vars)
    for app in app_hosts:
        if app in app_vars:
            app_dicts[app]['ip'] = app_hosts[app]
        else:
            #print app," has not vars"
            app_dicts.setdefault(app, {}).setdefault('ip', app_hosts[app])
    return app_dicts

app_vars = get_app_vars('/home/www/jenkins/ansible/vars')
app_hosts = get_app_hosts('/home/www/jenkins/ansible/hosts')
app_dicts = get_app_dicts(app_vars, app_hosts)

#print app_vars
#print app_dicts
