#!/bin/bash
# Adds a user to the git group.

function die () {
#    echo >&2 "$@"
	echo >&2 "Usage: addusertogitgroup.sh username"
    exit 1
}

if [ "$#" -lt 1 ];
then
	die
fi

dscl . append /Groups/git GroupMembership $1