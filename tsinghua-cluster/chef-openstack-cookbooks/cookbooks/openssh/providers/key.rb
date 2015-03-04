require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

action :create do
  ssh_keygen_node = node_election(new_resource.role, 'ssh_keygen')
  cmd = "cat /etc/passwd |grep ^#{new_resource.username}: | cut -d : -f 6"
  rc = shell_out(cmd)
  userhome = rc.stdout.strip
  private_key_file = "#{userhome}/.ssh/id_rsa"
  public_key_file = "#{userhome}/.ssh/id_rsa.pub"
  authorized_key_file = "#{userhome}/.ssh/authorized_keys"   
  if node.name.eql?(ssh_keygen_node.name) and ! node['openssh']['shared'].key?("#{new_resource.username}") 
    unless ::File.exist?(private_key_file)
      cmd = %Q/su - #{new_resource.username} -c "ssh-keygen -t rsa -q -f #{private_key_file} -P ''"/
      rc = shell_out(cmd)
    end
    pri_key = ::File.read(private_key_file)
    pub_key = ::File.read(public_key_file)
    node.set['openssh']['shared']["#{new_resource.username}"] = {
      'private_key' => pri_key,
      'public_key' => pub_key,
      'authorized_key' => pub_key
    }
    node.save
    if ::File.exist?(authorized_key_file)
      ruby_block authorized_key_file do
        block do
          auth_file = Chef::Util::FileEdit.new(authorized_key_file)
          auth_file.insert_line_if_no_match(pub_key, pub_key)
          auth_file.write_file
        end
      end
    else
      file "#{authorized_key_file}" do
        content node['openssh']['shared']["#{new_resource.username}"]['authorized_key']
        owner   new_resource.username
        group   new_resource.group
        mode    00600
      end
    end
    template "#{userhome}/.ssh/config" do
      source "config.erb"
      owner   new_resource.username 
      group   new_resource.group 
      mode    00600
    end 
  elsif !node.name.eql?(ssh_keygen_node.name) && !node['openssh']['shared'].key?("#{new_resource.username}")
    directory "#{userhome}/.ssh for ssh keys" do
      path "#{userhome}/.ssh"
      owner new_resource.username
      group new_resource.group
      mode "0700"
    end
    node.set['openssh']['shared']["#{new_resource.username}"] = {
      'private_key' => nil,
      'public_key' => nil,
      'authorized_key' => nil
    }
    node.save
    if ssh_keygen_node.attribute?('openssh')
      %w{private_key public_key authorized_key}.each do |key|
        uname = "#{new_resource.username}"
        unless ssh_keygen_node['openssh']['shared'][uname][key].nil?
          node.set['openssh']['shared']["#{new_resource.username}"][key] = ssh_keygen_node['openssh']['shared']["#{new_resource.username}"][key]
          node.save
          file eval("#{key}_file") do
            content node['openssh']['shared']["#{new_resource.username}"][key]
            owner   new_resource.username
            group   new_resource.group
            mode    00600
          end
        end
      end
    end
    template "#{userhome}/.ssh/config" do                                                           
      source "config.erb"                                                                           
      owner   new_resource.username                                                                 
      group   new_resource.group 
      mode    00600                                                                                 
    end
  #else
    ## TODO:
  end
end

