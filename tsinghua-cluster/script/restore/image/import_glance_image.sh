#!/bin/bash
#
# import_glance_image.sh	import image to glance 
#
# Author:			Kui Shi	<kui.shi@huawei.com>
#					<skuicloud@gmail.com>
#


set -x
# check the arguments
if [ $# != 3 ]; then
    echo "Usage: $0 <rc_file> <image_dir> \"<vm_id> <vm_id>\" "
    echo "Usage: $0 <rc_file> <image_dir> <vm_list_file>"
    exit 0
fi

BEGIN_TIME=$(date +%s)

rc_file=`readlink -f $1`
image_dir="$2"

if [ ! -d $image_dir ]; then
    echo "$image_dir does not exist."
    exit 1
else
    cd $image_dir
fi


image_list="$3"
if [ -f "$image_list" && ! `file $image_list |grep "Qemu Image"` ]; then
    image_list="`cat $image_list`"
fi


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

# loop all the image, and upload them
for i in ${image_list[@]};
do
    # get vm info (id / name )
    start_time=$(date +%s)
    vm_name=`nova show $i |grep '| name' | awk -F'|' '{print $3}'`
    vm_name=`echo $vm_name |sed 's/ //g'`
    id=$i

    echo "upload image: $i " | tee -a $log_file
    glance image-create   --file $i --name $i --disk-format=qcow2  --container-format=bare --is-public True
    #glance image-create --id  $i  --file $i --name $i --disk-format=qcow2  --container-format=bare --is-public True

    # stastistics
    end_time=$(date +%s)
    interval=$(($end_time - $start_time))
    ELAPSE_TIME=$((end_time - $BEGIN_TIME))

    image_size=`ls ${i} -lh | awk '{print $5}'`
    # save the vm info
    echo $id $vm_name >> $vm_info_file
    echo -e "\n#########################"  | tee -a $log_file
    echo -e "Image uploaded: ${i}  Size: $image_size  Used time: $interval  Elapse time: $ELAPSE_TIME"  | tee -a $log_file
    echo -e "#########################\n"   | tee -a $log_file
done
