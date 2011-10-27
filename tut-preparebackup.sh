#!/bin/bash
#
# This script can be used to build an backup archive and
# hand it of the network to a save host.

# The first version is very basic: It sends the
# backup over a plain TCP connection.
# The second one sends a TCP trigger to init scp transfer.
USE_SCP="" # change to yes to use scp. Default: no.

HOST="10.0.2.2"
PORT=1234
DIR=~/tut

# Options for scp
BACKUP_ARC=~/testing/backup.tar.gz

umask 077
TMP=`mktemp`
trap -- "rm -f $TMP" EXIT

# build archive
[ "$USE_SCP" != "yes" ] && BACKUP_ARC="$TMP"
cd $DIR/..
tar -czf "$BACKUP_ARC" ${DIR##*/}

if [ "$USE_SCP" == "yes" ]; then
	nc $HOST $PORT <<<"go"
else
	nc $HOST $PORT < $BACKUP_ARC
fi
submresult=$?

exit $submresult
