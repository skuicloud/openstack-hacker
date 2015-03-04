from fabric.api import run,sudo

def download_script(name=""):
    cmd = 'cd /var/lib/nova/instances;rm -f create_image.sh* vm_list; wget http://10.1.4.64/backup/create_image.sh'
    check_cmd = 'cd /var/lib/nova/instances; ls create_image.sh'
    prepare_nfs = 'cd /home/shikui; ls'
    sudo(cmd)
    sudo(check_cmd)
    sudo(prepare_nfs)

def push_vm_list(name=""):
    cmd = 'cd /var/lib/nova/instances; pwd; echo %s >>vm_list; cat vm_list' % name
    print("hello %s" % name)
    sudo(cmd)

def backup_vm():
    cmd = "cd /var/lib/nova/instances; sh create_image.sh ./ /home/shikui/backup_vm/ \"`cat vm_list` \" "
    sudo(cmd)

def date():
    run('date')

def ls():
    run('ls -l /root')

def df_h():
    run('df -h ')

def check_eth_order():
    run('ls -l /etc/udev/rules.d/70*')

def reboot():
    run('reboot')

def chef_client():
    run('chef-client -E tsinghua-ceph')

def chef_client_direct():
    run('chef-client')

def nic_driver():
    run('wget http://10.1.4.64/tool/driver.sh; sh driver.sh')
    #run('wget http://10.1.4.64/tool/driver.sh; sh driver.sh')

def repo_update():
    run('wget http://10.1.4.64/centos-repo/repo_update.sh; sh repo_update.sh')


def mount_var():
    run('wget http://10.1.4.64/tool/mount_var.sh; sh mount_var.sh')

def eth_order():
    run('wget http://10.1.4.64/tool/eth_order.sh; sh eth_order.sh')

def varvol():
    run('wget http://10.1.4.64/tool/varvol.sh; sh varvol.sh')

def resize_rootvol():
    run('wget http://10.1.4.64/lvm/resize.sh; sh resize.sh')

def check_nic_var():
    run('ls /root/MLNX_OFED_INSTALLED')
    run('ls /root/MOUNT_VAR')
    run('ls /root/VARVOL')

def kill_ceph():
    run('killall ceph-osd')

def check_repo():
    run('grep 65 /etc/yum.repos.d/CentOS-Base.repo ')

def check_varvol():
    run('lvdisplay   |grep varvol ')

def rc_local_chef():
    run('echo chef-client >> /etc/rc.local ')
    run('echo chef-client >> /etc/rc.local ')

def prepare_deploy():
    chef_client()
    repo_update()
    nic_driver()
    mount_var()
