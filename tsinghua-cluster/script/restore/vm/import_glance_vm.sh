#!/bin/bash
#
# import_glance_image.sh	import image to glance 
#
# Author:			Kui Shi	<kui.shi@huawei.com>
#					<skuicloud@gmail.com>
#


set -x
# check the arguments
if [ $# != 4 ]; then
    echo "Usage: $0 <rc_file> <image_dir> \"<vm_id> <vm_id>\" <vm_info_file> "
    echo "Usage: $0 <rc_file> <image_dir> <vm_list_file> <vm_info_file>"
    exit 0
fi

BEGIN_TIME=$(date +%s)

rc_file=`readlink -f $1`
image_dir="$2"

image_list="$3"
if [ -f "$image_list" ] && [ ! `file $image_list |grep "Qemu Image"` ]; then
    image_list="`cat $image_list`"
fi

vm_info_file=`readlink -f $4`


if [ ! -d $image_dir ]; then
    echo "$image_dir does not exist."
    exit 1
else
    cd $image_dir
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

# loop all the image, and upload them
for i in ${image_list[@]};
do
    # get vm info (id / name )
    start_time=$(date +%s)
    vm_name=`nova show $i |grep '| name' | awk -F'|' '{print $3}'`
    vm_name=`echo $vm_name |sed 's/ //g'`
    id=$i

    echo "upload image: $i " 
    user_name=`cat $vm_info_file  |grep $i  -C 12 |grep user_id |awk '{print $4}'`
    vm_name=`cat $vm_info_file  |grep $i  -C 12 |grep " name " |awk '{print $4}'`
    glance image-create   --file $i --name "vm-${user_name}-${vm_name}" --disk-format=qcow2  --container-format=bare --is-public True --progress
    #glance image-create --id  $i  --file $i --name $i --disk-format=qcow2  --container-format=bare --is-public True

    # stastistics
    end_time=$(date +%s)
    interval=$(($end_time - $start_time))
    ELAPSE_TIME=$((end_time - $BEGIN_TIME))

    image_size=`ls ${i} -lh | awk '{print $5}'`
    # save the vm info
    echo -e "\n#########################" 
    echo -e "Image uploaded: ${i}  Size: $image_size  Used time: $interval  Elapse time: $ELAPSE_TIME"
    echo -e "#########################\n"
done
