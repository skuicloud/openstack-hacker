#!/bin/bash
# Author: kui.shi@huawei.com  2014/8/19
# create image with qemu-img

# check the arguments
if [ $# != 3 ]; then
    echo "Usage: $0  <source_dir> <backup_dir>  \"<vm_id> <vm_id>\" "
    echo "Usage: $0  <source_dir> <backup_dir>  all "
    exit 0
fi

var_usage=`df --total  /var  |grep "^total " | awk '{print $5}' |sed 's/%//g'`
if [ $var_usage -gt 45 ]; then
     echo "***** /var partition usage is ${var_usage}%."
     echo "***** It is not enough to backup all the vm instance."
     exit 1
fi

echo "Save the vm instance on $HOSTNAME"

BEGIN_TIME=$(date +%s)

mkdir -p $2
source_dir=`cd $1; pwd`
backup_dir=`cd $2; pwd`
vm_id_list="$3"

# check the return value
err_trap()
{
    echo "[LINE:$1] command or function exited with status $?"
}
#trap 'err_trap $LINENO' ERR


# create file to save vm info in $backup_dir
current_time=`date +%Y%m%d%H%M%S`
vm_info_file=$backup_dir/vm_info_$current_time
log_file=$backup_dir/log_$current_time
failed_file=$backup_dir/failed_$current_time
touch $vm_info_file
touch $log_file
touch $failed_file

# loop all the vm, and download them
if [ "all" = "$vm_id_list" ]; then
    echo "all vm instances will be saved\n" 
    declare -a vm_id_list=(`cd $source_dir; ls *-*-*-*-* -1 ./ -d  |grep -v "\./"`)
    echo ${vm_id_list[@]}
fi

for i in ${vm_id_list[@]};
do
    snapshot_name=${i}
    disk_file="$source_dir/$snapshot_name/disk"
    image_file="$backup_dir/$snapshot_name"

    start_time=$(date +%s)

    echo "Saving VM instance: $i " | tee -a $log_file
    image_file=${backup_dir}/${snapshot_name}

    # get image format of the vm instance
    image_format=`qemu-img info $i/disk |grep "file format" |sed 's/.* //g'`
    echo "File format:  ${image_format}"  | tee -a $log_file

    # confirm the snapshot image
    echo "qemu-img convert -p -f ${image_format} -O qcow2  ${disk_file} ${image_file}" | tee -a $log_file
    qemu-img convert -p -f ${image_format} -O qcow2  ${disk_file} ${image_file}
    if [ 0 != $? ]; then
        echo "failed vm: $snapshot_name" >> $failed_file
        continue
    fi

    # stastistics
    end_time=$(date +%s)
    interval=$(($end_time - $start_time))
    ELAPSE_TIME=$((end_time - $BEGIN_TIME))

    image_size=`ls ${image_file} -lh | awk '{print $5}'`
    # save the vm info
    echo $id $vm_name >> $vm_info_file
    echo -e "\n#########################"  | tee -a $log_file
    echo -e "VM saved on [$HOSTNAME]: ${image_file}  Size: $image_size  Used time: $interval  Elapse time: $ELAPSE_TIME"  | tee -a $log_file
    echo -e "#########################\n"   | tee -a $log_file
done

echo -e "\n######################### Finished on [$HOSTNAME]  #########################\n"
