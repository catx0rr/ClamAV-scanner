## Installation instructions

### Installation
- copy avscan scripts directory to /root directory
- change permissions to 700 of each shell script

### Create a quarantine directory:

- create a directory named quarantine under /opt/clamav directory
- change permissions to 750 of quarantine directory

### Create a cronjob for the AVScan
```
0 11   * * 5 root /root/avscan/freshclam.sh
0 12   * * 5 root /root/avscan/clamscan.sh
```
- change permission of /etc/crontab to 640

### Create a log rotation for clamav scanner EOF
```
/var/log/clamav/clamav-scanner.log.old {
    size 1k
    copytruncate
    rotate 4
}
```

### Install sendemail (python email package)

- sudo apt-get install -y sendemail

### Encrypt the password of email account (alert account)
```
# openssl enc -e -aes-256-cbc -k <string> -pbkdf2 -a -iter <int> -iv <hex-values>

paste the password on passwd field variable on /root/avscan/clamscan.sh and /root/avscan/freshclam.sh
```

### Configure openssl aesdecrypt
```
- provide key
- provide iter
- provide iv
- add pbkdf2 to cipher
```

### Import function on /usr/bin directory
```
# cp ./function/aesdecrypt /usr/bin
# chown root:root /usr/bin/aesdecrypt
# chmod +x /usr/bin/aesdecrypt
```

### Test the AV Scanner and Updater

- systemctl disable --now clamav-freshclam.service
- run freshclam.sh and clamscan.sh
