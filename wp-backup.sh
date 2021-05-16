#!/bin/bash
# wp-backup.sh: This script will backup wp-config.php file and wp-content directory.
# https://github.com/nawawi/wp-backup.sh

# Script base path
_BASEPATH="/opt/wp-operation";

# Website base path
_SRCPATH="/opt/website";

# Backup store path
_DSTPATH="${_BASEPATH}/wp-backup";


_RDATE="$(date +"%Y-%m-%d %H:%M:%S")";
_LOCKFILE="${_DSTPATH}/wp-backup-sh.lock";
_MYSQLDUMP="$(type -p mysqldump)";
_DOS2UNIX="$(type -p dos2unix)";

if [ ! -d $_BASEPATH ]; then
    echo "$_BASEPATH not exist";
    exit 1;
fi

if ! cd $_BASEPATH &>/dev/null; then
    echo "Cannot change directory to $_BASEPATH";
    exit 1;
fi

[ ! -d $_DSTPATH ] && mkdir -pv $_DSTPATH;
if ! cd $_DSTPATH &>/dev/null; then
    echo "Cannot change directory to $_DSTPATH";
    exit 1;
fi

if [ ! -d $_SRCPATH ]; then
    echo "$_SRCPATH not exist";
    exit 1;
fi

if [ ! -x "${_MYSQLDUMP}" ]; then
	echo "mysqldump binary not found";
	exit 1;
fi

if [ -f "${_LOCKFILE}" ]; then
    echo "process run";
    exit 1;
fi

trap "{ rm -f $_LOCKFILE; exit 1; }" SIGINT SIGTERM SIGHUP SIGKILL SIGABRT EXIT;
touch $_LOCKFILE;

for _CONF in $_SRCPATH/*/wp-config.php; do
    [ ! -f $_CONF ] && continue;

    $_DOS2UNIX $_CONF;

    _DBNAME="$(grep DB_NAME ${_CONF} | sed -e "s/.*,\s'\(.*\)');/\1/" -e "s/.*,\s'\(.*\)'\s);/\1/" |tr -d '\r')";
    _DBUSER="$(grep DB_USER ${_CONF} | sed -e "s/.*,\s'\(.*\)');/\1/" -e "s/.*,\s'\(.*\)'\s);/\1/" |tr -d '\r')";
    _DBPASS="$(grep DB_PASSWORD ${_CONF} | sed -e "s/.*,\s'\(.*\)');/\1/" -e "s/.*,\s'\(.*\)'\s);/\1/" |tr -d '\r')";

    [ "x${_DBNAME}" = "x" ] && continue;
    [ "x${_DBUSER}" = "x" ] && continue;
    [ "x${_DBPASS}" = "x" ] && continue;

    _BF="$(dirname $_CONF)";
    _DF="$(basename $_BF)";
    [ "x${_DF}" = "x" ] && continue;

    mkdir -pv $_DSTPATH/$_DF;
    [ ! -d "${_DSTPATH}/${_DF}" ] && continue;

    echo "# BACKUP: ${_BF}"; 
    cp -fv $_CONF $_DSTPATH/$_DF/;
    cp -fav $_BF/wp-content $_DSTPATH/$_DF/;

    if [ -d "${_DSTPATH}/$_DF/wp-content/cache/" ]; then
        rm -rfv $_DSTPATH/$_DF/wp-content/cache/;
    fi

    $_MYSQLDUMP -u$_DBUSER -p$_DBPASS --single-transaction --add-drop-database --add-drop-table $_DBNAME > $_DSTPATH/$_DF/$_DF.sql;

    if [ -d "./${_DF}" ]; then
        tar -zcvf $_DF.tgz $_DF;
        if [ $? = 0 ]; then
            rm -rf ./$_DF;
        fi
    fi
done

echo $_RDATE > $_DSTPATH/last-wp-backup-sh.txt;
rm -f $_LOCKFILE;
exit 0;
