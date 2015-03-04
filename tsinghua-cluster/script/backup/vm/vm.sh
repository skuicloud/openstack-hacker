#!/bin/bash
# Backup designated VM from compute node via qemu-img
# Author: kui.shi@huawei.com  2015/1/31

if [ $# != 2 ]; then
    echo "Usage: $0 <openrc> <backup_vm_list_file>"
    exit 0
fi

# backup_vm_list_file sample
# username-1   vm-name-1   07b08bd5-666e-4dbb-987e-b64d46f9f0f4 
# username-2   vm-name-2   ec5cb557-2ae9-4ab4-b950-ae455bbe8db1

# For fab command
run_cmd () {
  fab -H root@10.1.0.$1 $2:name=$3 -p "$pswd"
}

openrc=`readlink -f $1`
backup_vm_list=`readlink -f $2`

. $openrc

# get compute node passwd
stty -echo
read -p "Input you password of compute node: "  pswd
stty echo

# download create_image.sh
# save the backup vm ids
echo "" > tmp_list
for i in  `cat $backup_vm_list  |awk '{print $3}'` 
do 
  host=`nova show $i |grep "OS-EXT-SRV-ATTR:host" | awk '{print $4}'|sed -e 's:^n::g' -e 's:^0::g'`
  echo $host
  if ! grep "^$host" tmp_list; then
    run_cmd $host download_script $i 
  fi
  echo $host $i >> tmp_list
  run_cmd $host push_vm_list $i 
done 

set -x
host_list="`cat tmp_list |awk '{print $1}'| uniq`"

host_ip_list=""
for i in $host_list; do
  host_ip="10.1.0.$i"
  if test "$host_ip_list" != ""; then
    host_ip_list="$host_ip,$host_ip_list"
  else
    host_ip_list="$host_ip"
  fi
done

echo $host_ip_list
fab -u root -p $pswd -H $host_ip_list backup_vm
