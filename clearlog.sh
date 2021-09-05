#!/bin/bash

# CentOS 7 ONLY

service rsyslog stop
cd /var/log

>boot.log
>cron
>dmesg
>dmesg.old
>maillog
>spooler
>wtmp
>btmp
>lastlog
>messages
>secure
>tallylog

rm -f ~/.bash_history
history -cw && shutdown -h now