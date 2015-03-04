#!/bin/sh
################################################################################################
## author : zengguoshi
## date : 2014-08-08
## description : A shell to auto back database per weeks and auto clean the expire bak files
################################################################################################


# A recommend deploy method is using the command as below:
#
# delpoy as a root cronjob:
#     (crontab -l -u root 2>&1 | grep -q backUpDB.sh) || echo '@weekly   /bin/sh backUpDB.sh >> /var/log/dbbackUpJob.log 2>&1' >> /var/spool/cron/root
# 
# deploy as a mysql cronjob:
#     (crontab -l -u mysql 2>&1 | grep -q backUpDB.sh) || echo '@weekly   /bin/sh backUpDB.sh >> /var/log/dbbackUpJob.log 2>&1' >> /var/spool/cron/mysql 
#
# if the script is not in a dir of '~' ,but in a path ,as '/var/lib/',then deploy like : 
#     (crontab -l -u mysql 2>&1 | grep -q backUpDB.sh) || echo '@weekly  cd /var/lib;/bin/sh backUpDB.sh >> /var/log/dbbackUpJob.log 2>&1' >> /var/spool/cron/mysql
# 
# if you want to specify the time point  that execute the script,deploy as: ( do job at 4:00 am per week )
#     (crontab -l -u root 2>&1 | grep -q backUpDB.sh) || echo '0 4 */7 * *   /bin/sh backUpDB.sh >> /var/log/dbbackUpJob.log 2>&1' >> /var/spool/cron/root 

# datatabase connection Info 
# you should provide a user with the adminstrator role to execute the dump operation
# general ,the user must have the privileges on read all dbs ,lock tables ...and someting need a high privileges.
DB_UserName=root ## the db administrator user
DB_Password=test ## the password for the admin user
DB_Host=localhost


## if you have database of keystone to backup,please set:skipTokenInKeystone=1 
## to skip backup the large tokens store in table token.
## if have not,please set to 0,otherwise ,it will raise some error info about cannot find database of keystone.
## but the frame of token table will be backed up.
## please add databases to the DB_BackupSchemas to backup them.
## if you want back up keystone,please specify it's name,
## because someone may set keystone as a name different from the default name of "keystone"
## exp:
## 	skipTokenDataInKeystone=1
##	NameofKeystoneDB="keystone"
##	DB_BackupSchemas="keystone glance"
skipTokenDataInKeystone=1
NameofKeystoneDB="keystone" # you should change it if you ever change the keystone's name.
DB_BackupSchemas="ceilometer cinder glance heat horizon keystone neutron nova" # the default dbs belongs to icehouse.

## we should delete the expires bak file after created  a new backed file.
## it will find the file which end with the string value defined in DB_BackedFileEndWith.
## We choose "Ops.bak" as the default end string to specify the backup file of Openstack's DB. 
## Set DB_RemainBackCnt to a value according the needing,to reserve some bak file created before.
## the default value is 5.
DB_BackedFileEndWith="Ops.bak.gz"
DB_RemainBackCnt=7 ## the count of the reserved back files
BackPath='/var/lib/backUp/'

## the log file logging some info of the back process.
LogPath='/var/log/openStack_DBBackUp/'
LogFile="${LogPath}backUp.log"


if [ ! -d "$BackPath" ];then
        mkdir "${BackPath}"
fi

if [ ! -d "$LogPath" ];then
        mkdir "${LogPath}"
fi

if [ ! -f "$LogFile" ];then
        touch "$LogFile"
fi

cur_Time=`date "+TM%Y%m%d%H%M%S"`
#echo $cur_Time

echo "start back up database" >> $LogFile

backFileName="openStackDB_${cur_Time}"
# echo $backFileName
bakTmpFile="${backFileName}.bak"
zipName="${backFileName}.${DB_BackedFileEndWith}"
# echo $zipName

cd ${BackPath}

## backup the frame of token ,but skip the record in it.
if [ $skipTokenDataInKeystone == 1 ];then
	mysqldump -h ${DB_Host} -u ${DB_UserName} --password=${DB_Password} --databases ${DB_BackupSchemas} --ignore-table=${NameofKeystoneDB}.token > "${bakTmpFile}"
	
	echo -e "\n## Here back up the table frame of token in database of keystone.\n USE ${NameofKeystoneDB};\n" >>"${bakTmpFile}"
	mysqldump -h ${DB_Host} -u ${DB_UserName} --password=${DB_Password} ${NameofKeystoneDB} token --no-data >> "${bakTmpFile}"
else
	mysqldump -h ${DB_Host} -u ${DB_UserName} --password=${DB_Password} --databases ${DB_BackupSchemas} > "${bakTmpFile}"
fi

# be aware of not using a directly path to tar
tar -zcf $zipName ${bakTmpFile} --remove-files

# list the all bak file 
cnt=0
## catch the files end with '.bak' and display these order by time desc,
## so the files in the bottom are the earlier files to be removed.
fileList=$(ls -t | grep "${DB_BackedFileEndWith}")
# echo ${DB_BackedFileEndWith}

for fileName in $fileList
do 
  	# echo $fileName
	let cnt++
	# echo $cnt
	
	if [ $DB_RemainBackCnt -lt $cnt ]; then
		rm -f $fileName
	fi	
done

echo -e "end back up ,file in ${zipName} \n" >> $LogFile
