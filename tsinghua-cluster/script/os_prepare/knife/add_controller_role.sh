#!/bin/bash


echo ${BASH_ARGV[@]}

for i in ${BASH_ARGV[@]} ; do 
    if [ "$i" -lt "10" ] ; then
       name=openstack.n00$i.2
    elif [ "$i" -lt "100" ]; then
       name=openstack.n0$i.2
    else
       name=openstack.n$i.2
    fi
    echo $name
    knife node run_list add  $name "role[base], role[os-identity], role[os-dashboard], role[os-image],role[os-compute-controller], role[os-network-server], role[os-block-storage-controller],role[centos-base]  "
done
