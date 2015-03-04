#!/bin/bash


for i in ${BASH_ARGV[@]} ; do 
  fab -u root -p root -H 10.1.0.$i chef_client_direct
done
