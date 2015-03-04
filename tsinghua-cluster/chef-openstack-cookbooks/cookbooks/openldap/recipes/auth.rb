#
# Cookbook Name:: openldap
# Recipe:: auth
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "openldap::client"
include_recipe "openssh"
include_recipe "nscd"

package "nss-pam-ldapd" do
  action :upgrade
end

#service "nslcd" do
#  action :nothing
#  supports :status => true, :start => true, :stop => true, :restart => true
#end

execute "authconfig" do
  command "authconfig --update"
  action :nothing
end

template "/etc/nslcd.conf" do
  source "nslcd.conf.erb"
  mode 00644
  owner "root"
  group "root"
end

template "#{node['openldap']['dir']}/ldap.conf" do
  source "ldap-ldap.conf.erb"
  mode 00644
  owner "root"
  group "root"
end

template "/etc/pam_ldap.conf" do
  source "pam_ldap.conf.erb"
  mode 00644
  owner "root"
  group "root"
end

template "/etc/nsswitch.conf" do
  source "nsswitch.conf.erb"
  mode 00644
  owner "root"
  group "root"
  #notifies :run, "execute[nscd-clear-passwd]", :immediately
  #notifies :run, "execute[nscd-clear-group]", :immediately
  notifies :run, "execute[authconfig]", :delayed
end

#%w{ account auth password session }.each do |pam|
#  cookbook_file "/etc/pam.d/common-#{pam}" do
#    source "common-#{pam}"
#    mode 00644
#    owner "root"
#    group "root"
#    notifies :restart, "service[ssh]", :delayed
#  end
#end

template "/etc/sysconfig/authconfig" do
  source "authconfig.erb"
  mode 00644
  owner "root"
  group "root"
end

template "/etc/pam.d/system-auth" do
  source "system-auth.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :run, "execute[authconfig]", :delayed
  #notifies :restart, "service[nscd]", :delayed
  notifies :restart, "service[ssh]", :delayed
end

