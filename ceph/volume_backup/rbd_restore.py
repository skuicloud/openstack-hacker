#!/usr/bin/python
# restore volume from the backup image
# Author: Kui.Shi skuicloud@gmail.com
#                 skuicloud@163.com
#
# Usage: rbd_restore.py <NFS_DIR> <backup_image_id>
# Required package: python-cinderclient, python-keystoneclient

import argparse
import os
import subprocess
import sys
import time

from cinderclient import client


TIMEOUT = 10
RBD = "/usr/bin/rbd"
_PIPE = subprocess.PIPE

def validate_arg():
    """ validate the arguments

        - check if the backup volume has a specific dir in nfs_dir.
        - return the list of volume path
        - sampl nfs dir structure
          nfs_dir/
            `-- backup_volume
                |-- backup.log
                `-- volume-af33986b-f387-4f98-9a26-fab0d84edca1
                    |-- volume-af33986b-f387-4f98-9a26-fab0d84edca1
                    `-- volume-af33986b-f387-4f98-9a26-fab0d84edca1_snapshot-ae1607f7-c502-4555-bfdb-f846cc50103d
    """

    # get the arguments
    parser = argparse.ArgumentParser(
        description='restore volume from the backup image')
    parser.add_argument('--nfs', metavar='nfs_dir', dest='nfs_dir', type=str)
    parser.add_argument('--volume-id', metavar='backup_volume_id', nargs='+')
    args = parser.parse_args()

    # compose the volume backup dir
    backup_volume_dir = os.path.join(os.path.abspath(args.nfs_dir), "backup_volume")
    full_volume_id = map(lambda m: "volume-" + m, args.volume_id)
    valid_volumes = []

    # loop all the volumes to check if the volume backup dir exist
    for vol in list(set(full_volume_id)):
        backup_path = os.path.join(backup_volume_dir, vol)
        if os.path.exists(os.path.join(backup_path, vol)):
            valid_volumes.append(backup_path)
        else:
            print("No backup volume for %s" % vol[7:])

    return list(valid_volumes)


def wait_for(volume):
    """ wait for volume is available"""

    # update volume status, wait unitl it is available.
    time.sleep(3)
    start = time.time()
    while(volume.status.upper() != "available".upper()):
        try:
            volume = volume.manager.get(volume.id)
        except Exception as e:
            raise e

        time.sleep(1)
        if time.time() - start > TIMEOUT:
            print("Timeout error while creating new volume: %s" % str(volume.id))
            raise Exception

    return volume


def create_volume():
    """ create new volume for restoring """

    # credential info
    OS_USERNAME = os.environ.get('OS_USERNAME', None) or "admin"
    OS_PASSWORD = os.environ.get('OS_PASSWORD', None) or "admin"
    OS_TENANT_NAME = os.environ.get('OS_TENANT_NAME', None) or "admin"
    OS_AUTH_URL = os.environ.get('OS_AUTH_URL', None) or "http://10.1.4.4:5000/v2.0"

    # cinderclient
    cinder = client.Client('1', OS_USERNAME, OS_PASSWORD, OS_TENANT_NAME, OS_AUTH_URL)

    # create the placeholder volume.
    # it creates entry in database, and an empty volume in ceph.
    # this volume will be removed while restoring, so here creates a 1GB volume.
    volume = cinder.volumes.create('1')
    volume = wait_for(volume)

    return volume

def restore_volume(new_volume, backup_volume):
    """ restore the backup volume """

    # remove the empty volume
    rm_cmd = str(RBD + " rm " + "volumes/" + "volume-" + (str(new_volume.id)))
    #print "rm_cmd", rm_cmd
    obj = subprocess.Popen(rm_cmd, stdin=_PIPE, stdout=_PIPE, stderr=_PIPE, shell=True) 
    
    # get backup image and snapshots
    # sort the backup images by file creating time.
    files = os.listdir(backup_volume)
    files.sort(key=lambda x: os.stat(os.path.join(backup_volume,x)).st_ctime)

    # full import the base image firstly
    # then import-diff the incremental diff
    import_opt = " import "
    for file in files:
        abs_file = os.path.abspath(os.path.join(backup_volume, file))
        cmd = str( RBD + import_opt + abs_file + " volumes/" + "volume-" + (str(new_volume.id)))
        #print "cmd", cmd
        obj = subprocess.Popen(cmd, stdin=_PIPE, stdout=_PIPE, stderr=_PIPE, shell=True) 
        import_opt = " import-diff "

    #     Original volume        New volume
    print files[0][7:] + "   " + str(new_volume.id)


if __name__ == "__main__":
    # get valid backup volume
    valid_backups = validate_arg()

    if valid_backups:
        print("Original volume" + " " * 24 + "New volume")
        print("-" * 36 + "   " + "-" * 36)

    # loop the backup volume, restore them one by one
    for backup_volume in valid_backups:
        new_volume = create_volume()
        restore_volume(new_volume, backup_volume)

