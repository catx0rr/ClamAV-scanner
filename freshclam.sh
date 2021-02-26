#!/bin/bash

source aesdecrypt

# ClamAV Definitions updater

# Pre-requisites:
# 	ClamAV, Freshclam and sendmail (python package)
# 		sudo apt-get install clamav freshclam sendemail -y
#		sudo dnf install clamav freshclam sendemail -y

# remove all variable comments after providing values.

email=""                                        # email alert bot
pass=""                                         # aes-256-cbc encrypted password 
recipient=""                                    # main recepient
cc=""                                           # cc emails (comma separated)
smtp_svr=smtp.server.com:587                    # smtp server typically followed by :587 (tls)
timestamp=$(date +'%m-%d-%y %H:%M:%S')
logfile=/var/log/clamav/clamavupdate.log

function freshclam-notify 
{
    sleep 5
	
    sendemail -q \
        -f $email \
        -t $recipient \
        -cc $cc \
        -u "[ClamAV updated its virus definitions on $(hostname)]" \
        -m "$(cat $logfile)" \
	    -s $smtp_svr \
        -xu $email \
        -xp "$(echo $pass | aesdecrypt)" \
	    -o tls=auto 2> /var/tmp/clamavfailed.log
	
}

function freshclam-updater
{
	cat $logfile /var/log/clamav/clamavupdate.log.old 2>/dev/null
	
    rm -rf $logfile 2>/dev/null

	echo -e "[$timestamp] Initialized AV definitions update on $(hostname)" >> $logfile
	
    freshclam | tee -a $logfile

    echo -e "[$timestamp] Freshclam updated. Check $logfile if there are errors." >> $logfile

    freshclam-notify
}

function main 
{
	freshclam-updater
}

main

