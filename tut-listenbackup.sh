#!/bin/bash
#
# This script can be used to receive a backup initiation
# from the test (virtual) machine.

# The first version is very basic: It expects to receive the
# backup over a plain TCP connection.
# The second one listens for a TCP trigger to connect to the
# test machine's ssh server and fetches the backup with scp.
USE_SCP="" # change to yes to use scp. Default: no.

LISTEN_PORT=1234
BACKUP_DEST="${1:-~/stud/tut_bs/backups}"

# Options for scp
SSH_PORT=8022
SSH_USER="gucki"
SSH_HOST="localhost"
BACKUP_SRC="~/testing/backup.tar.gz"

umask 077
TMP=`mktemp`
trap -- "rm -f $TMP" EXIT

while true; do
	echo -n "waiting for client trigger..."
	nc -l $LISTEN_PORT > $TMP
	if [ $? -ne 0 ]; then
		echo "abort" >&2
		exit 1
	fi

	fname=`date +"%Y-%m-%d_%H-%M-%S"`.tar.gz
	if [ "$USE_SCP" == "yes" ]; then
		# Don't care about TMP's content. Any content is a good trigger...
		scp -P $SSH_PORT $SSH_USER@$SSH_HOST:$BACKUP_SRC "$BACKUP_DEST/$fname"
	else
		cp $TMP "$BACKUP_DEST/$fname"
	fi
	> $TMP # truncate TMP
	echo "  backup writen: $fname"
done

exit 0
