#!/bin/sh

BASE=$PWD

if [ $# -eq 0 ] ; then
	echo "Usage: `basename $0` email@example.com"
	exit 127
fi

if [ $# -eq 1 ] ; then
	find . -type d -name .git | xargs -n 1 $0 $1
else
	echo "# $2 #"
	cd $PWD/$2
	zeitgit enable $1
	echo ""
fi

