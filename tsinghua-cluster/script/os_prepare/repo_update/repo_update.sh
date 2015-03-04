#!/bin/bash

REPOFILES="CentOS-Base CentOS-Debuginfo CentOS-Media CentOS-Vault epel"

# Update repo file to use local repos
for name in $REPOFILES; do
    wget http://10.1.4.64/centos-repo/"$name".repo -O /etc/yum.repos.d/"$name".repo
done

yum clean all
yum update -y
