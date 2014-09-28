#!/usr/bin/env sh
# This script is used to remove the app installed
# Author: cann

#---------------------------
#---------------------------
APPNAME=
VERSION=
GROUP_ID=com.tgx.app
NPATH=/usr/local/nxfetch
INSTALLDIR=/usr/local



usage(){
cat<<EOF

usage: $0 -options /$appName
eg: $0  -v 1.0.0 TgxQueenServer

OPTIONS:
	-h	Show this message
	-v	version
	-i	install path
	-p 	nx base path
EOF

default options values:
	v ---- all versions
	p ---- /usr/local/nxfetch
}


#read the options
while getopts "hv:p:i:" OPTION
do
	case $OPTION in
	h)
		usage
		exit
		;;
	v)
		VERSION=$OPTARG
		;;
	p)
		NPATH=$OPTARG
		;;
	i)
		INSTALLDIR=$OPTARG
		;;
	?)
		exit
		;;
	esac
done



#check the agrs
checkAgrs(){
	if [ -z $APPNAME ]
	then
		echo "Error: missing the appName input."
		echo "Use $0 help to see more."
		exit 1
	fi
} 


#remove the app
removeApp(){

if [ ! -z $VERSION ]
then
	#echo "$INSTALLDIR/$APPNAME-$VERSION."
	if [ -d $INSTALLDIR/$APPNAME-$VERSION ]
	then 
		echo "deleting app files."
		echo "DELETE: $INSTALLDIR/$APPNAME-$VERSION"
		sleep 2
		rm -r $INSTALLDIR/$APPNAME-$VERSION	
	else
		echo "this version not found, check the installed list."
	fi
else
	#FILEE=`ls $INSTALLDIR/$APPNAME*`
	if [ ! -d $INSTALLDIR/$APPNAME* ]
	then
		echo "no installed app version found."
	else
		echo "deleting app files............"
		echo "DELETE: $INSTALLDIR/$APPNAME*"
		sleep 2
		rm -r $INSTALLDIR/$APPNAME*
	fi
fi
}

#case the input agrs
case "$1" in
	'help')
		echo "This is the help msg"
		exit
		;;
	*)
		APPNAME=$(eval "echo \$$#")
		checkAgrs	
		removeApp
		;;

esac

