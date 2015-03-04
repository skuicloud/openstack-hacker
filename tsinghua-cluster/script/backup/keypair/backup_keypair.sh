#!/bin/bash
set -x
backFile=/var/lib/mysql/nova/keypaire_back_file
if [ -e $backFile ];then
  rm -f $backFile
fi
user='root'
pass='openstack'
db='nova'
host='10.1.0.205'

mysql -h $host  -u$user -p$pass -D $db -e "select name,public_key from key_pairs into outfile 'keypaire_back_file' fields terminated by '|';"

mv $backFile ./keypaire_back_file

if [ -e "/var/lib/mysql/keypaire_back_file" ];then
 rm -f /var/lib/mysql/keypaire_back_file
fi
