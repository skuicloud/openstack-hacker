#!/bin/bash

# use parted to partion
yum  install -y  parted
yum  install -y  expect

# make GPT
expect << EOF
spawn parted /dev/sdf mklabel gpt
expect "*Yes/No?"
send Yes\r
expect eof
EOF

# get disk size
disk_size=`parted /dev/sdf p |grep "^Disk " | awk -F : '{print $2}'`
echo $disk_size

# partion the disk, one primary partion occupy all the space
parted /dev/sdf p
parted /dev/sdf mkpart primary 1 $disk_size 

# make ext3 fs, it will take a few minutes for a 3TB disk
mkfs.ext3 /dev/sdf1 

# backup original /var
rm -f /root/var.tgz
cd /var
tar -zcvf /root/var.tgz * 
cd /

# mount /dev/sdf1
mount /dev/sdf1 /var

# restore /var
cd /var
tar -zxvf /root/var.tgz

# add entry in /etc/fstab
sed -i -e 's:.* /var .*::g' /etc/fstab
echo "/dev/sdf1 /var   ext3    defaults 1 1" >> /etc/fstab
touch  /root/MOUNT_VAR
#reboot
