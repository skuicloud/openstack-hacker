openssh_key "SSH login without password" do
  role node['openssh']['passwordless']['role']
  username "root"
  group "root"
  action :create
end

openssh_key "SSH login without password" do
  role node['openssh']['passwordless']['role']
  username "nova"
  group "nova"
  action :create
end
