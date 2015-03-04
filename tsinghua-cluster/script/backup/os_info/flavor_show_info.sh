#!/bin/bash
# Author: kui.shi@huawei.com  2014/8/20
# show all flavor info


#set -x
# check the arguments
if [ $# != 3 ]; then
    echo "Usage: $0 <rc_file> <save_info_file> all"
    exit 0
fi

BEGIN_TIME=$(date +%s)

rc_file=`readlink -f $1`
vm_info_file="$2"
vm_id_list="$3"

# check the return value
err_trap()
{
    echo "[LINE:$1] command or function exited with status $?"
}
#trap 'err_trap $LINENO' ERR

# source the OS variables
source $rc_file

# check the connection to OpenStack
nova list >/dev/null 2>&1


echo "" >$vm_info_file

# loop all the vm, and show them
if [ "all" = "$vm_id_list" ]; then
    echo "all vm will be saved\n" 
    declare -a vm_id_list=(`nova flavor-list  |grep "|" |grep -v "ID *| Name" | awk -F '|' '{print $2}'`)
    echo ${vm_id_list[@]}
fi

for i in ${vm_id_list[@]};
do
    # get vm info (id / name )
    start_time=$(date +%s)
    echo "nova flavor-show $i"
    nova flavor-show $i >> $vm_info_file 

    # stastistics
    end_time=$(date +%s)
    interval=$(($end_time - $start_time))
    ELAPSE_TIME=$((end_time - $BEGIN_TIME))

    # save the vm info
    echo -e "\n#########################"  | tee -a $log_file
    echo -e "flavor saved: ${image_file}  Used time: $interval  Elapse time: $ELAPSE_TIME"  | tee -a $log_file
    echo -e "#########################\n"   | tee -a $log_file
done

