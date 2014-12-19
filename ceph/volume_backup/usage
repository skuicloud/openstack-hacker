=============
rbd_backup.sh
=============

# rbd ls -p volumes
volume-2012c27d-de04-487b-9eab-0eef9780272d
volume-a4507a92-0a22-43f4-9148-c11a3e7913f2
volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f

# rbd snap ls volumes/volume-2012c27d-de04-487b-9eab-0eef9780272d

# rbd snap ls volumes/volume-a4507a92-0a22-43f4-9148-c11a3e7913f2
SNAPID NAME                                             SIZE 
   121 snapshot-7a014f27-81ee-4450-b28e-e95784ee94d3 2048 MB 
   122 snapshot-fe468392-22c7-4936-8637-86589d3b4376 2048 MB 

# rbd snap ls volumes/volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f
SNAPID NAME                                             SIZE 
   123 snapshot-8b972ed9-2e9e-41ea-8bed-eb2528526554 3072 MB 
   124 snapshot-3d367d72-91d5-4008-b52f-f2072f37f3bf 3072 MB 
   125 snapshot-f6dc8986-eda0-4bbf-a408-f8505e09501c 3072 MB 
   126 snapshot-9a60fc34-36c2-4445-8cdf-20e1ef3cbc34 3072 MB 
   127 snapshot-19116729-4469-47d6-bd45-d37a0529dbfd 3072 MB 



# ./rbd_backup.sh  nfs_dir 

# tree nfs_dir/
nfs_dir/
`-- backup_volume
    |-- backup.log
    |-- volume-a4507a92-0a22-43f4-9148-c11a3e7913f2
    |   |-- volume-a4507a92-0a22-43f4-9148-c11a3e7913f2
    |   `-- volume-a4507a92-0a22-43f4-9148-c11a3e7913f2_snapshot-fe468392-22c7-4936-8637-86589d3b4376
    `-- volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f
        |-- volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f
        `-- volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f_snapshot-19116729-4469-47d6-bd45-d37a0529dbfd

3 directories, 5 files


# cinder snapshot-create ebbf124a-be04-459d-a0ea-79c1aff59e0f

# ./rbd_backup.sh  nfs_dir 

# tree nfs_dir/
nfs_dir/
`-- backup_volume
    |-- backup.log
    |-- volume-a4507a92-0a22-43f4-9148-c11a3e7913f2
    |   |-- volume-a4507a92-0a22-43f4-9148-c11a3e7913f2
    |   `-- volume-a4507a92-0a22-43f4-9148-c11a3e7913f2_snapshot-fe468392-22c7-4936-8637-86589d3b4376
    `-- volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f
        |-- snapshot-19116729-4469-47d6-bd45-d37a0529dbfd_snapshot-642c5a21-4275-4064-b7d9-d74b6acd3927
        |-- volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f
        `-- volume-ebbf124a-be04-459d-a0ea-79c1aff59e0f_snapshot-19116729-4469-47d6-bd45-d37a0529dbfd

3 directories, 6 files


==============
rbd_restore.sh
==============

# ./rbd_restore.py  --nfs nfs_dir/  --volume-id a4507a92-0a22-43f4-9148-c11a3e7913f2  ebbf124a-be04-459d-a0ea-79c1aff59e0f                                        
Original volume                        New volume
------------------------------------   ------------------------------------
a4507a92-0a22-43f4-9148-c11a3e7913f2   9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e
ebbf124a-be04-459d-a0ea-79c1aff59e0f   a58d5eba-f39f-4a21-8b33-2da155b01e6d


# rbd info volumes/volume-9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e 
rbd image 'volume-9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e':
	size 2048 MB in 512 objects
	order 22 (4096 kB objects)
	block_name_prefix: rbd_data.40917489eae16
	format: 2
	features: layering

# rbd info volumes/volume-a58d5eba-f39f-4a21-8b33-2da155b01e6d 
rbd image 'volume-a58d5eba-f39f-4a21-8b33-2da155b01e6d':
	size 3072 MB in 768 objects
	order 22 (4096 kB objects)
	block_name_prefix: rbd_data.4091c4bad1710
	format: 2
	features: layering

# rbd snap ls volumes/volume-9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e
SNAPID NAME                                             SIZE 
   136 snapshot-fe468392-22c7-4936-8637-86589d3b4376 2048 MB 

# rbd snap ls volumes/volume-a58d5eba-f39f-4a21-8b33-2da155b01e6d 
SNAPID NAME                                             SIZE 
   137 snapshot-19116729-4469-47d6-bd45-d37a0529dbfd 3072 MB 


# cinder show 9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e 
+--------------------------------+--------------------------------------+
|            Property            |                Value                 |
+--------------------------------+--------------------------------------+
|          attachments           |                  []                  |
|       availability_zone        |                 nova                 |
|            bootable            |                false                 |
|           created_at           |      2014-12-19T03:29:03.000000      |
|      display_description       |                 None                 |
|          display_name          |                 None                 |
|           encrypted            |                False                 |
|               id               | 9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e |
|            metadata            |                  {}                  |
|     os-vol-host-attr:host      |            OS-controller             |
| os-vol-mig-status-attr:migstat |                 None                 |
| os-vol-mig-status-attr:name_id |                 None                 |
|  os-vol-tenant-attr:tenant_id  |   4d8e5916481f48bf862726b62941fe8d   |
|              size              |                  1                   |
|          snapshot_id           |                 None                 |
|          source_volid          |                 None                 |
|             status             |              available               |
|          volume_type           |                 None                 |
+--------------------------------+--------------------------------------+


# cinder show a58d5eba-f39f-4a21-8b33-2da155b01e6d  
+--------------------------------+--------------------------------------+
|            Property            |                Value                 |
+--------------------------------+--------------------------------------+
|          attachments           |                  []                  |
|       availability_zone        |                 nova                 |
|            bootable            |                false                 |
|           created_at           |      2014-12-19T03:29:08.000000      |
|      display_description       |                 None                 |
|          display_name          |                 None                 |
|           encrypted            |                False                 |
|               id               | a58d5eba-f39f-4a21-8b33-2da155b01e6d |
|            metadata            |                  {}                  |
|     os-vol-host-attr:host      |            OS-controller             |
| os-vol-mig-status-attr:migstat |                 None                 |
| os-vol-mig-status-attr:name_id |                 None                 |
|  os-vol-tenant-attr:tenant_id  |   4d8e5916481f48bf862726b62941fe8d   |
|              size              |                  1                   |
|          snapshot_id           |                 None                 |
|          source_volid          |                 None                 |
|             status             |              available               |
|          volume_type           |                 None                 |
+--------------------------------+--------------------------------------+


# cinder snapshot-list |grep a58d5eba-f39f-4a21-8b33-2da155b01e6d
# cinder snapshot-list |grep 9e1c2f48-ed32-4e7c-8a5b-1334f1625f2e 
// nothing here, no need to create snapshot via cinderclient
