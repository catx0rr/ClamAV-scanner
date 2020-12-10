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
smtp_svr=smtp.gmail.com:587
timestamp=$(date +'%m-%d-%y %H:%M:%S')
logfile=/var/log/clamav/clamav-scanner.log

function clamav-scanner 
{
	cat $logfile >> /var/log/clamav/clamav-scanner.log.old 2>/dev/null
	rm -rf $logfile 2>/dev/null

	echo -e "[$timestamp] Initialized Full disk scan on $(hostname)
Scanning on target directories recursively..
$(ls -ldb /* | awk -F' ' '{print $9}' | sed '3d;11d;16d;')

Excluded directories:
/sys
/dev
/proc\n" >> $logfile

	# Uncomment this line and comment out 2nd clamscan line for testing.
	#clamscan / --exclude-dir='^/sys|^/dev|^/proc' >> $logfile

	# Default full disk scanner 
	clamscan / --recursive \
	 --cross-fs=yes \
	 --infected \
	 --heuristic-scan \
	 --move=/opt/clamav/quarantine \
	 --max-filesize=250M \
	 --max-scansize=250M \
	 --exclude-dir='^/sys|^/dev|^/proc' >> $logfile

	echo -e "[$timestamp] Scanning done." >> $logfile

}

function clamav-notify 
{
	sendemail -f $email -t $recipient -cc $cc -u "[ClamAV scanned $(hostname)]" -m "$(cat $logfile)" \
	-s $smtp_svr -xu $email -xp "$(echo $pass | base64 -d | tr A-Za-z N-ZA-Mn-za-m)" \
	-q 2> /var/log/clamav/clamavsendfailed.log

}

function main 
{
	clamav-scanner
	clamav-notify
}

main
