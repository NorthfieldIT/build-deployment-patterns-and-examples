# encoding: utf-8
# Cookbook Name:: random-jenkins
# Recipe:: default
#

include_recipe 'yum::default'

package 'git' do
  action :upgrade
end

include_recipe 'users::sysadmins'
include_recipe 'sudo::default'
include_recipe 'firewall::default'

ports = node['random-jenkins']['open_ports']
firewall_rule "open ports #{ports}" do
  port ports
end

include_recipe 'jenkins::java'
include_recipe 'jenkins::master'

package 'gcc' do
  action :upgrade
end

package 'python'
package 'python-devel'
package 'python-setuptools'

easy_install_package 'pip' do
  action :install
end

python_package 'fabric' do
  action :install
end
python_package 'PyCrypto' do
  version '2.3'
  action :install
end

yum_repository 'nodejs-4x' do
  description 'NodeJS packages'
  baseurl 'https://rpm.nodesource.com/pub_4.x/el/7/$basearch'
  gpgcheck false
  action :create
end

package 'nodejs'

nodejs_npm 'npm' do
  version '3.8.9'
end

nodejs_npm 'jspm' do
  version '0.16.2'
end

nodejs_npm 'npm-cache' do
  version '0.6.0'
end

include_recipe 'ssh-hardening::default'
include_recipe 'ssh-hardening::unlock'
include_recipe 'os-hardening::default'
