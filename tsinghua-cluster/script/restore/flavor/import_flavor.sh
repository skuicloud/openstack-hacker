#!/bin/bash
# import flavor based on info of "nova flavor-show"
#
# Author: skuicloud@gmail.com
#         skuicloud@163.com
#
# Usage: import_flavor.sh  <openrc> <flavor_info_file>


# check the arguments
if [ $# != 2 ]; then
    echo "Usage: $0  <openrc> <flavor_info_file>"
    exit 0
fi

rc_file=`readlink -f $1`
flavor_file=`readlink -f $2`

if [ ! -f "$rc_file" ] ; then
    echo "$rc_file does not exist."
    exit 1
fi

if [ ! -f "$flavor_file" ]; then
    echo "$flavor_file does not exist."
    exit 1
fi


flavor_names=`cat flavor_info  |grep "| name"  |awk '{print $4}'`

for i in ${flavor_names[@]};
do
    if `nova flavor-show $i >/dev/null 2>&1`; then
        echo "$i already exist"
    else
        cat flavor_info  |grep "| $i"  -C 5 > tmp_flavor

        ephemeral=`cat tmp_flavor  |grep "OS-FLV-EXT-DATA:ephemeral"  |awk '{print $4}'` 
        os_flv_disabled=`cat tmp_flavor  |grep "OS-FLV-DISABLED:disabled"  |awk '{print $4}'` 
        disk=`cat tmp_flavor  |grep "| disk"  |awk '{print $4}'` 
        extra_specs=`cat tmp_flavor  |grep "| extra_specs"  |awk '{print $4}'` 
        is_public=`cat tmp_flavor  |grep "os-flavor-access:is_public"  |awk '{print $4}'` 
        ram=`cat tmp_flavor  |grep "| ram"  |awk '{print $4}'` 
        rxtx_factor=`cat tmp_flavor  |grep "rxtx_factor"  |awk '{print $4}'` 
        vcpus=`cat tmp_flavor  |grep "| vcpus"  |awk '{print $4}'` 
        echo 
        echo 
        echo $i $ephemeral  ${os_flv_disabled} $disk  $extra_specs  $is_public  $ram  $rxtx_factor $vcpus 
        echo "Creating flavor: $i"
        set -x
        nova flavor-create --ephemeral $ephemeral --is-public ${is_public} --rxtx-factor ${rxtx_factor} $i auto ${ram} ${disk} ${vcpus}
        set +x
        rm -f rxtx_factor
    fi
done
