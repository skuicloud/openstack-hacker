#!/bin/bash

# remove varvol
varvol=`lvdisplay   |grep  varvol |grep "LV Path"  | awk '{print $3}'`
expect << EOF
spawn lvremove  $varvol
expect "*\[y/n\]:"
send y\r
expect eof
EOF


# extend rootvol
free_pe=`vgdisplay   |grep "Free  PE"  |awk '{print $5}'`
rootvol=`lvdisplay   |grep  rootvol |grep "LV Path"  | awk '{print $3}'`
current_pe=`lvdisplay  $rootvol |grep "Current LE" |awk '{print $3}'`
echo $free_pe
echo $current_pe
new_pe=`expr $free_pe + $current_pe`
lvextend -l $new_pe $rootvol


lvdisplay
touch VARVOL
