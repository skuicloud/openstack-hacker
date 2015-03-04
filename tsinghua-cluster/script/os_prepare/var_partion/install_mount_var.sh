#!/bin/bash

host_ip_list=""
for i in ${BASH_ARGV[@]} ; do 
  host_ip="10.1.0.$i"
  if test "$host_ip_list" != ""; then
    host_ip_list="$host_ip,$host_ip_list"
  else
    host_ip_list="$host_ip"
  fi
done

echo $host_ip_list

fab -u root -p root -H $host_ip_list mount_var
