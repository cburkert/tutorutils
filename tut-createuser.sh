#!/bin/bash
#
# This script lists the commands to create the
# restricted user and group which can be used
# to enhance protection of tutorsh.
# Root privileges are required.

# Customize the following user and group names
# NORMALUSER should be the user who runs tutorsh
# and has full access to the students solutions.
NORMALUSER="christian"
CORRECTOR="tutcorr"
CORRECTGRP="tutgrp"

# You may want to use your .vimrc or bash history which
# are expected to be in CORRECTOR's home directory.
# Unset CORRHOME to avoid the creation of a home dir.
CORRHOME="/home/$CORRECTOR"

set -e
addgroup $CORRECTGRP
adduser $NORMALUSER $CORRECTGRP

if [ -n "$CORRHOME" ]; then
	adduser --home "$CORRHOME" --ingroup $CORRECTGRP $CORRECTOR
else
	adduser --no-create-home --ingroup $CORRECTGRP $CORRECTOR
fi

echo "Re-login to effect group add."

exit 0
