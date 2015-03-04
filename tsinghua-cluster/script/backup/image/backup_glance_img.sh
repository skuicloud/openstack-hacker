#!/bin/bash
# Author: kui.shi@huawei.com  2014/8/12
# download glance image


#set -x
# check the arguments
if [ $# != 3 ]; then
    echo "Usage: $0 <rc_file> <save_img_dir>  \"<vm_id> <vm_id>\" "
    echo "Usage: $0 <rc_file> <save_img_dir>  all "
    exit 0
fi

BEGIN_TIME=$(date +%s)

rc_file=`readlink -f $1`
backup_dir="$2"
image_list="$3"

mkdir -p $backup_dir

# check the return value
err_trap()
{
    echo "[LINE:$1] command or function exited with status $?"
}
#trap 'err_trap $LINENO' ERR

# source the OS variables
source $rc_file

# check the connection to OpenStack
glance image-list >/dev/null 2>&1


# create file to save vm info in $backup_dir
current_time=`date +%Y%m%d%H%M%S`
vm_info_file=$backup_dir/vm_info_$current_time
log_file=$backup_dir/log_$current_time
failed_file=$backup_dir/failed_$current_time
touch $vm_info_file
touch $log_file
touch $failed_file

# loop all the vm, and download them
if [ "all" = "$image_list" ]; then
    echo "all vm will be saved\n" 
    declare -a image_list=(`glance image-list --all-tenants |grep "|" |grep -v "ID *| Name" | awk -F '|' '{print $2}'`)
    echo ${image_list[@]}
fi

for i in ${image_list[@]};
do
    image_file=${i}-image

    # get vm info (id / name )
    start_time=$(date +%s)
    image_name=`glance image-show $i |grep '| name' | awk -F'|' '{print $3}'`
    image_name=`echo $image_name |sed 's/ //g'`
    id=$i

    echo "Saving VM: $i ${vm_name}" | tee -a $log_file
    save_file=${backup_dir}/${image_file}-${image_name}

    # download the image
    echo "glance image-download --file ${save_file} ${i}"  | tee -a $log_file
    glance image-download --progress --file ${save_file} ${i}
    touch ${save_file}


    # stastistics
    end_time=$(date +%s)
    interval=$(($end_time - $start_time))
    ELAPSE_TIME=$((end_time - $BEGIN_TIME))

    image_size=`ls ${save_file} -lh | awk '{print $5}'`
    # save the vm info
    echo $id $vm_name >> $vm_info_file
    echo -e "\n#########################"  | tee -a $log_file
    echo -e "VM saved: ${image_file}  Size: $image_size  Used time: $interval  Elapse time: $ELAPSE_TIME"  | tee -a $log_file
    echo -e "#########################\n"   | tee -a $log_file
done


# print statistics
echo "VM downloaded: "  $(wc -l ${vm_info_file} | awk '{print $1}')  | tee -a $log_file
echo "VM failed: " $(wc -l ${failed_file} | awk '{print $1}')  | tee -a $log_file

