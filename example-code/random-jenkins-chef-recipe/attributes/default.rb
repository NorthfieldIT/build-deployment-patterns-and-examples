# encoding: utf-8
default['authorization']['sudo']['groups'] = ['sysadmin']
default['authorization']['sudo']['passwordless'] = true

default['firewall']['allow_ssh'] = true
default['firewall']['firewalld']['permanent'] = true
default['random-jenkins']['open_ports'] = [8080]

default['jenkins']['master']['install_method'] = 'war'
default['jenkins']['master']['version'] = '2.17'

default['nodejs']['packages'] = %w(nodejs nodejs-devel)
