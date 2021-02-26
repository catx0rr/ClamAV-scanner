#!/bin/bash

source aesdecrypt

# ClamAV Full Disk Scheduler

# Pre-requisites:
# 	ClamAV, Freshclam and sendmail (python package)
# 		sudo apt-get install clamav freshclam sendemail -y
#		sudo dnf install clamav freshclam sendemail -y

# remove all variable comments after providing values.

email=""                                    # email alert bot
pass=""                                     # aes-256-cbc encrypted password
recipient=""                                # main recepient
cc=""                                       # cc emails (comma separated)
smtp_svr=smtp.server:587                    # smtp server typically follwed by :587 (tls)

timestamp=$(date +'%m-%d-%y %H:%M:%S')  
logfile=/var/log/clamav/clamav-scanner.log
infected=$(cat $logfile | grep -i "infected" | awk -F' ' '{print $3}')
message="There is a malware detected on the host system on last ClamavScan.
Check log or quarantine folder immediately for more info.

If the issue is already resolved, you may ignore this message."

function clamav-notify 
{
    sleep 5 
    
    sendemail -q \
        -f $email \
        -t $recipient \
        -cc $cc \
        -u "[ClamAV scanned $(hostname)]" \
        -m "$(cat $logfile)" \
	    -s $smtp_svr \
        -xu $email \
        -xp "$(echo $pass | aesdecrypt)" \
	    -o tls=auto 2>/dev/null
}

function clamav-malware-notify
{
	sleep 5
	
    sendemail -q \
        -f $email \
        -t $recipient \
        -cc $cc \
        -u "[MALWARE Detected on $(hostname)]" \
        -m "$message" \
	    -s $smtp_svr \
        -xu $email \
        -xp "$(echo $pass | aesdecrypt)" \
		-o tls=auto 2>/dev/null
}

function malware-check
{
    sleep 2

	if [ "$infected" -ne 0 ]; then
		clamav-malware-notify
	fi		
}

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

    sleep 2
	
    echo -e "[$timestamp] Scanning done." >> $logfile

 	clamav-notify
}

function main 
{
	clamav-scanner
    malware-check
}

main
