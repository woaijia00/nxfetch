#!/usr/bin/env sh
# This script is used to search App in the nexus server

#---------------------------
HOST=localhost:8081
REPO=releases

NPATH=/usr/local/nxfetch
INSTALLDIR=/usr/local
DISTDIR=$NPATH/dist
#---------------------------
APPNAME=
VERSION=
GROUP_ID=com.tgx.app



usage(){
cat<<EOF

usage: $0 -options /$appName
eg: $0 -v 1.0.0 -p /usr/local/nxfetch TgxQueenServer

OPTIONS:
	-h	Show this message
	-v 	version
	-r	repositories
	-n	nexus host addr
	-p	nx base path
	-i	install path
	-g	group id

default options values:
	g ---- com.tgx.app
	v ---- latest
	r ---- releases
	n ---- localhost:8081
	p ---- /usr/local/nxfetch

EOF
}

for LAST; do true; done
APPNAME=$LAST

#read the options
while getopts "hv:p:i:r:n:g:" OPTION
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
		DISTDIR=$NPATH/dist
		;;
	i)	INSTALLDIR=$OPTARG
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


#check the dir
checkDir(){
	if [ ! -d $DISTDIR ]
	then 
		echo "WARNING: the dist dir--${NPATH}/dist not found, creating it."
		mkdir -p $DISTDIR
	fi
	if [ ! -d $INSTALLDIR ]
	then 
		echo "WARNING: the install dir--$INSTALLDIR not found, creating it."
		mkdir  -p $INSTALLDIR
	fi
}

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
	if [ -z $VERSION ]
	then
		echo "fetch version from:"
		echo "http://${HOST}/nexus/service/local/lucene/search?repositoryId=$REPO&g=${GROUP_ID}&a=${APPNAME}"
		VERSION=$( curl --silent "http://${HOST}/nexus/service/local/lucene/search?repositoryId=$REPO&g=${GROUP_ID}&a=${APPNAME}" | sed -n 's|<latestRelease>\(.*\)</latestRelease>|\1|p' | sed -e 's/^[ \t]*//' | tail -1 )
	fi
}

downloadApp(){
	checkDir
	echo "fetching artifact from:"
	echo "http://${HOST}/nexus/service/local/artifact/maven/redirect?r=${REPO}&g=${GROUP_ID}&a=${APPNAME}&e=zip&v=${VERSION}"
	curl -o ${DISTDIR}/${APPNAME}-${VERSION}.zip -L -#  "http://${HOST}/nexus/service/local/artifact/maven/redirect?r=${REPO}&g=${GROUP_ID}&a=${APPNAME}&e=zip&v=${VERSION}"
}

# unzip the app and install
installApp(){
	if [ -d ${DISTDIR}/${APPNAME}-${VERSION} ]
	then
		echo "deleting the exist file."
		rm -rf ${DISTDIR}/${APPNAME}-${VERSION}
	fi
	
	echo "unziping the artifact....."
	unzip -d ${DISTDIR} ${DISTDIR}/${APPNAME}-${VERSION}.zip
	echo "installing to $INSTALLDIR......"
	cp -rf ${DISTDIR}/${APPNAME}-${VERSION} ${INSTALLDIR}/${APPNAME}-${VERSION} 
	rm -rf ${DISTDIR}/${APPNAME}-${VERSION}
	sleep 2
	echo "Done."
}

#case the input agrs
case "$1" in
	'help')
		echo "This is the help msg"
		exit
		;;
	*)
		checkAgrs	
		getVersion
		downloadApp
		installApp
		;;

esac

