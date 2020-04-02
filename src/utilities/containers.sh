#!/bin/sh

# Returns the gnomonfile on path and sends and error if not found
#	$1 (req): the path to check
#	$2 (opt): error level if $1 is not a gnomon repository (1 : fatal | 2 : warning)
#	output : gnomonfile
getGnomonfile(){ 
	local path="$1/.gnomonfile"
	if [ -f $path ]
	then
		gnomonfile="$path"
	else
		gnomonfile=""
		case $2 in
			1) exitIfError 1 "$1 is not a Gnomon Container" ;;
			2) logWarning "$1 is not a Gnomon Container"; return 1;;
			0|*);;
		esac
	fi 
}

# Extracts the name from a path
#	$1 (req): the path ending with the name
#	$2 (opt): the extension to remove
#	output :  name_from_path
nameFromPath(){
	local name="${1##*/}"

	if [ -n $2 ]
	then
		local name="${name/$2/}"
	fi

	name_from_path="$name"
}