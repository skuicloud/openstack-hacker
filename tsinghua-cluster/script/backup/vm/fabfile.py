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
