#
# Cookbook Name:: memcached
# Recipe:: default
#
# Copyright 2009-2013, Opscode, Inc.
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

# include epel on redhat/centos 5 and below in order to get the memcached packages
include_recipe 'yum-epel' if node['platform_family'] == 'rhel' && node['platform_version'].to_i == 5

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

package 'memcached'

package 'libmemcache-dev' do
  case node['platform_family']
  when 'rhel', 'fedora'
    package_name 'libmemcached-devel'
  when 'smartos'
    package_name 'libmemcached'
  when 'suse'
    if node['platform_version'].to_f < 12
      package_name 'libmemcache-devel'
    else
      package_name 'libmemcached-devel'
    end
  else
    package_name 'libmemcache-dev'
  end
end

service 'memcached' do
  action :enable
  supports :status => true, :start => true, :stop => true, :restart => true, :enable => true
end

if !node['memcached']['bind_interface'].nil?
  node.set['memcached']['listen'] = address_for(node['memcached']['bind_interface'])
end

case node['platform_family']
when 'rhel', 'fedora', 'suse'
  family = node['platform_family'] == 'suse' ? 'suse' : 'redhat'
  template '/etc/sysconfig/memcached' do
    source "memcached.sysconfig.#{family}.erb"
    owner 'root'
    group 'root'
    mode  '0644'
    variables(
      :listen          => node['memcached']['listen'],
      :user            => node['memcached']['user'],
      :group           => node['memcached']['group'],
      :port            => node['memcached']['port'],
      :udp_port        => node['memcached']['udp_port'],
      :maxconn         => node['memcached']['maxconn'],
      :memory          => node['memcached']['memory'],
      :max_object_size => node['memcached']['max_object_size'],
      :logfilename     => node['memcached']['logfilename']
    )
    notifies :restart, 'service[memcached]'
  end
when 'smartos'
  # SMF directly configures memcached with no opportunity to alter settings
  # If you need custom parameters, use the memcached_instance provider
  service 'memcached' do
    action :enable
  end
else
  template '/etc/memcached.conf' do
    source 'memcached.conf.erb'
    owner  'root'
    group  'root'
    mode   '0644'
    variables(
      :listen          => node['memcached']['listen'],
      :user            => node['memcached']['user'],
      :port            => node['memcached']['port'],
      :udp_port        => node['memcached']['udp_port'],
      :maxconn         => node['memcached']['maxconn'],
      :memory          => node['memcached']['memory'],
      :max_object_size => node['memcached']['max_object_size']
    )
    notifies :restart, 'service[memcached]'
  end
end
