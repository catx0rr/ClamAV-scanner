# Clamav Full disk scheduler


### Pre-requisites

- clamav
- freshclam
- sendemail (python package)

### Installing packages

You might need community repository to install packages

Fedora / Centos / RedHat:

```
sudo dnf install epel-release -y
sudo dnf install clamav freshclam sendemail -y

```
Ubuntu / Debian:

```
sudo apt-get install clamav freshclam sendemail -y
```

#### This is fully tested on Ubuntu / CentOS systems.

### Set Up:

- Copy the clamav directory under root directory
```
sudo cp clamav /root/
sudo chmod -R 700 /root/clamav
```
- Create a cron job to automatically perform a scheduled scan
    - run updater every 11pm and full system scan on 12mn
```
sudo chmod 660 /etc/crontab

* 23 * * * root /root/clamav/clamscan.sh
* 00 * * * root /root/clamav/freshclam.sh
```

- Setup email alerting and modify the script
    - clamscan.sh
    - freshclam.sh
