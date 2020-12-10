#!/bin/bash

# ClamAV Full Disk Scheduler

# Pre-requisites:
# 	ClamAV, Freshclam and sendmail (python package)
# 		sudo apt-get install clamav freshclam sendemail -y
#		sudo dnf install clamav freshclam sendemail -y

email=
pass=
recipient=
cc=
smtp_svr=
timestamp=$(date +'%m-%d-%y %H:%M:%S')
logfile=/var/log/clamav.log

function clamav-scanner 
{
	rm -rf $logfile 2>/dev/null

	echo -e "[$timestamp] Initialized Full disk scan on $(hostname)
Scanning on target directories recursively..
$(ls -ldb /* | awk -F' ' '{print $9}' | sed '3d;11d;16d;')" >> $logfile

	# Uncomment this line and comment out 2nd clamscan line for testing.
	#clamscan / --exclude-dir='^/sys|^/dev|^/proc' >> $logfile

	# Default full disk scanner 
	clamscan / --recursive \
	 --infected \
	 --heuristic-scan \
	 --exclude-dir='^/sys|^/dev|^/proc' >> $logfile

	echo -e "[$timestamp] Scanning done." >> $logfile

}

function clamav-notify 
{
	sendemail -f $email -t $recipient -cc $cc -u "[ClamAV scanned $(hostname)]" -m "$(cat $logfile)" \
        -s $smtp_svr -xu $email -xp "$(echo $pass)" \
	-q 2> /var/tmp/clamavfailed.log

	rm -rf $logfile
}

function main 
{
	clamav-scanner
	clamav-notify
}

main
