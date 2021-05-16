# wp-backup.sh
WordPress Backup Bash Script

## Description

Auto Backup WordPress wp-config.php and wp-content for multiple websites. This script only for standard WordPress installation, Bedrock users may need to modify the source and destination path.

## Prerequisite

1. dos2unix
2. mysqldump
3. tar
4. bash


## Installation

1.  Create working directory

```sh
$ sudo mkdir -p /opt/wp-operation
```

2. Copy this script

```sh
sudo wget https://raw.githubusercontent.com/nawawi/wp-backup.sh/main/wp-backup.sh -O /opt/wp-operation/wp-backup.sh
sudo chmod 755 /opt/wp-operation/wp-backup.sh
```

3. Set _SRCPATH. This script will scan for multiple websites, for example:

/home/webapp/website1/wp-config.php  
/home/webapp/website2/wp-config.php  
/home/webapp/website3/wp-config.php

your _SRCPATH is a "/home/webapp"

_SRCPATH="/home/webapp";

## Usage

1. Run manually
   
```sh
sudo /opt/wp-operation/wp-backup.sh
```

2. Using Cronjob

Add to /etc/crontab

```sh
# wp-backup 5:40am
40 5 * * * root /opt/wp-operation/wp-backup.sh &>/dev/null
```

Reload crond

```sh
sudo systemctl reload crond
```


