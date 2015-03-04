#!/bin/bash

size=`lvdisplay |grep rootvol -C 10  |grep "LV Size"  |awk '{print $3}' |sed -e 's:\..*::g'`
volume=`lvdisplay  |grep "LV Path" |grep rootvol |awk '{print $3}'`
resize2fs $volume ${size}G 
echo $size $volume
