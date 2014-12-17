#!/bin/bash
# rbd incremental backup the snapshot in the "volumes" pool
#
# Author: skuicloud@gmail.com
#         skuicloud@163.com
#
# Usage: rbd_backup.sh <NFS_DIR>

SOURCEPOOL="volumes"

NFS_DIR="$1"
if [[ -z "$NFS_DIR" ]]; then
    echo "Usage: rbd_backup.sh <NFS_DIR>"
    exit 1
fi

BACKUP_DIR="$NFS_DIR/backup_volume"
LOG_FILE="$BACKUP_DIR/backup.log"
mkdir -p $BACKUP_DIR
touch $LOG_FILE

#list all volumes in the pool
IMAGES=`rbd ls $SOURCEPOOL`

for LOCAL_IMAGE in $IMAGES; do

	#check if there is snapshot to backup
	LATEST_SNAP=`rbd snap ls $SOURCEPOOL/$LOCAL_IMAGE |grep -v "SNAPID" |sort -r | head -n 1 |awk '{print $2}'`
	if [[ -z "$LATEST_SNAP" ]]; then
		echo "info: no snap for $SOURCEPOOL/$LOCAL_IMAGE to backup" >>$LOG_FILE
                continue
	fi

        # the first snapshot backup
	# 1. full export base image
        # 2. export-diff the first snapshot
        IMAGE_DIR="$BACKUP_DIR/$DESTPOOL/$LOCAL_IMAGE"
        if [[ ! -e "$IMAGE_DIR" ]]; then        
                mkdir -p "$IMAGE_DIR"
                # full export the image
                echo "rbd export $SOURCEPOOL/$LOCAL_IMAGE $IMAGE_DIR/${LOCAL_IMAGE}" >>$LOG_FILE
                rbd export $SOURCEPOOL/$LOCAL_IMAGE $IMAGE_DIR/${LOCAL_IMAGE}  >/dev/null 2>&1

                # export-diff the first snapshot
                echo "rbd export-diff $SOURCEPOOL/$LOCAL_IMAGE@$LATEST_SNAP \
                                      $IMAGE_DIR/${LOCAL_IMAGE}_${LATEST_SNAP}" >>$LOG_FILE
                rbd export-diff $SOURCEPOOL/$LOCAL_IMAGE@$LATEST_SNAP \
                                $IMAGE_DIR/${LOCAL_IMAGE}_${LATEST_SNAP}  >/dev/null 2>&1
                continue
        fi
       
        # export-diff the snapshot from last one
        LAST_SNAP=`ls $IMAGE_DIR -1 -rt |tail -n 1|awk -F_ '{print $2}'`
        echo "rbd export-diff --from-snap $LAST_SNAP $SOURCEPOOL/$LOCAL_IMAGE@$LATEST_SNAP \
                                          $IMAGE_DIR/${LAST_SNAP}_${LATEST_SNAP}" >>$LOG_FILE
        rbd export-diff --from-snap $LAST_SNAP $SOURCEPOOL/$LOCAL_IMAGE@$LATEST_SNAP \
                                    $IMAGE_DIR/${LAST_SNAP}_${LATEST_SNAP}  >/dev/null 2>&1

done
