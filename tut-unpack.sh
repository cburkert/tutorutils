#!/bin/bash
# Replace all spaces in the given file/dir names by
# underscores or a given character

PROG="${0##*/}"
VERSION="0.1"

function usage() {
	cat <<-EOF
	$PROG [Options] File... Destination

	Options:
	  -n, --no-check     skip test of archive structure
	  -f, --force        overwrite existing files
	  -h, --help         display this information
	  -v, --verbose      verbose output
	EOF
}

SHORTOPT="hvfn"
LONGOPT="help,verbose,force,no-check"

# parse options
OPTS=$(getopt -s bash -o "$SHORTOPT" -l "$LONGOPT" \
	-n "$PROG" -- "$@") || exit $?

# reset the proceeded options into the positional parameters
eval set -- "$OPTS"

while true ; do
	case "$1" in
		-f|--force) force="yes"; shift;;
		-n|--no-check) nocheck="yes"; shift;;
		-v|--verbose) verbose="yes"; shift;;
		-h|--help) usage; exit 0;;
		--) shift; break;; # end of option list
		*) echo "Internal error!" >&2 ; exit 23;;
	esac
done

# check arguments
if [ $# -lt 2 ]; then
	echo "Error: missing argument" >&2
	usage
	exit 1
fi

function errlog () {
	[ -n "$verbose" ] && tee -a "$ERR" || cat >> "$ERR"
}

DST="$(eval echo \${$#})"
ERR="unpack-error.log"
> "$ERR" # trunc logfile
PATTERN="^asst[0-9]/[0-9]*/"

while [ $# -gt 1 ]; do
	arc="$1"
	shift

	if [ ! -r $arc ]; then
		echo "$arc: no read permission" | errlog
		continue
	fi

	if [ -z "$nocheck" ]; then
		tar --list --auto-compress --file "$arc" 2>/dev/null \
			| grep --quiet --regexp="$PATTERN"
		if [ $? -ne 0 ]; then
			echo "$arc: bad archive structure" | errlog
			continue
		fi
	fi

	[ -n "$force" ] && overwrite="--overwrite" || overwrite="--keep-old-files"
	{
		tar --extract --auto-compress $overwrite --directory $DST \
			--file $arc 2>/dev/null || echo "$arc extraction failed";
	} |& errlog
done

exit 0
