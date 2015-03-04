#!/bin/bash

set -x
cd /etc/udev/rules.d

rm -f  70-persistent-net.rules-orig
cp -f 70-persistent-net.rules 70-persistent-net.rules-orig

sed -i -e 's:eth4:eth4-old:g' \
       -e 's:eth5:eth5-old:g' \
       -e 's:eth6:eth4:g' \
       -e 's:eth7:eth5:g' \
70-persistent-net.rules 


sed -i -e 's:eth4-old:eth6:g' \
       -e 's:eth5-old:eth7:g' \
70-persistent-net.rules 


diff 70-persistent-net.rules-orig 70-persistent-net.rules

echo 
