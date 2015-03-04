#!/bin/bash

export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://10.1.1.251:5000/v2.0
export OS_REGION_NAME=RegionOne

export ext_net_id='741b1424-5303-4a43-b62c-95d40ad69840 '

export i=2

for tenant in $(keystone tenant-list | grep True | awk '{print $2 "," $4}'); do
    tenant_id=$(echo "$tenant" |cut -f 1 -d ',')
    tenant_name=$(echo "$tenant"|cut -f 2 -d ',')
    if [[ $tenant_name == 'service' ]] || [[ $tenant_name == 'admin' ]] ; then
        continue
    fi
    neutron net-list |grep "net-$tenant_name" > /dev/null
    if [ $? -ne 0 ]; then
        echo "tenant_id=$tenant_id,   tenant_name=$tenant_name"
        net_id=$(neutron net-create --tenant-id "$tenant_id" "net-$tenant_name" |awk '/ id/ {print $4}')
        subnet_id=$(neutron subnet-create --tenant-id "$tenant_id" "net-$tenant_name" 172.20.$i.0/24 |awk '/ id/ {print $4}')
        router_id=$(neutron router-create --tenant-id $tenant_id router-$tenant_name |awk '/ id/ {print $4}')
        neutron  router-interface-add $router_id $subnet_id
        neutron router-gateway-set $router_id $ext_net_id
        export i=$((i+1))
    fi
done
