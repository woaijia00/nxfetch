#!/usr/bin/env sh
# This script is used to check App version in the nexus server

#---------------------------
HOST=localhost:8081
REPO=releases
#---------------------------
APPNAME=
VERSIONS=
GROUP_ID=com.tgx.app



usage(){
cat<<EOF

usage: $0 -options /$appName
eg: $0  TgxQueenServer

OPTIONS:
	-h	Show this message
	-r	repositories
	-n	nexus host addr
	-g	group id

default options values:
	g ---- com.tgx.app
	r ---- releases
	n ---- localhost:8081

EOF
}


#read the options
while getopts "hg:r:n:" OPTION
do
	case $OPTION in
	h)
		usage
		exit
		;;
	r)
		REPO=$OPTARG
		;;
	n)
		HOST=$OPTARG
		;;
	g)
		GROUP_ID=$OPTARG
		;;
	?)
		usage
		exit
		;;
	esac
done



#check the agrs
checkAgrs(){
	if [ -z $APPNAME ]
	then
		echo "Error: missing the appName input"
		exit 1
	fi
} 

#get the latest version of the app
getVersion(){
	
	echo "starting to fetch from:"
	echo "http://${HOST}/nexus/service/local/lucene/search?repositoryId=${REPO}&g=${GROUP_ID}&a=${APPNAME}"

	if [ -z $VERSIONS ]
	then
		VERSIONS=$( curl --silent "http://${HOST}/nexus/service/local/lucene/search?repositoryId=${REPO}&g=${GROUP_ID}&a=${APPNAME}" | sed -n 's|<version>\(.*\)</version>|\1|p' | sed -e 's/^[ \t]*//' )
	fi
	
	if [ -z "$VERSIONS" ]
	then
		echo "no version found, please check the appName."	
	else
		echo "the $APPNAME versions:"
		echo $VERSIONS
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
		getVersion
		;;

esac

