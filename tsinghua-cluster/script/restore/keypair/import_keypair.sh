#!/bin/bash
backFile=./keypair_back_file
tmpFile=./temp_keypaire_file

#enviroment='/root/openrc'
#source $enviroment

while read line
do
    name=$(echo $line | awk -F '|' '{print $1}')
    pub_key=$(echo $line | awk -F '|' '{print $2}')
    echo "$pub_key" > ./$tmpFile
    nova keypair-add --pub-key ./$tmpFile $name
done < $backFile

if [ -e $tmpFile ];then
  rm -f $tmpFile
fi
