#!/bin/bash

# ClamAV Definitions updater

# Pre-requisites:
# 	ClamAV, Freshclam and sendmail (python package)
# 		sudo apt-get install clamav freshclam sendemail -y
#		sudo dnf install clamav freshclam sendemail -y

email=
pass=
recipient=
cc=
smtp_svr=smtp.gmail.com:587
timestamp=$(date +'%m-%d-%y %H:%M:%S')
logfile=/var/log/clamav/clamavupdate.log

function freshclam-updater
{
	cat $logfile /var/log/clamav/clamavupdate.log.old
	rm -rf $logfile 2>/dev/null

	echo -e "[$timestamp] Initialized AV definitions update on $(hostname)" >> $logfile
	freshclam | tee -a $logfile
	echo -e "[$timestamp] Freshclam updated. Check $logfile if there are errors." >> $logfile

}

function freshclam-notify 
{
	sendemail -f $email -t $recipient -cc $cc -u "[ClamAV updated its virus definitions on $(hostname)]" -m "$(cat $logfile)" \
	-s $smtp_svr -xu $email -xp "$(echo $pass | base64 -d | tr A-Za-z N-ZA-Mn-za-m)" \
	-q 2> /var/log/clamav/clamavsendfailed.log

}

function main 
{
	freshclam-updater
	freshclam-notify
}

main
