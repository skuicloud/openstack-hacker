#
# Cookbook Name:: mountnfs
# Recipe:: default
#
# Copyright 2014, Wei Xu
#
# All rights reserved - Do Not Redistribute
#

package "autofs" do
  action :upgrade
end

package "nfs-utils" do
  action :upgrade
end

service "autofs" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

service "rpcidmapd" do
  action :nothing
  supports :status => true, :start => true, :stop => true, :restart => true
end

directory "/project" do
  owner "root"
  group "root"
  mode 00777
  action :create
end

template "/etc/idmapd.conf" do
  source "idmapd.conf.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[rpcidmapd]", :delayed
end

template "/etc/auto.master" do
  source "auto.master.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[autofs]", :delayed
end

template "/etc/auto.nfs" do
  source "auto.nfs.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[autofs]", :delayed
end

template "/etc/auto.project" do
  source "auto.project.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[autofs]", :delayed
end
