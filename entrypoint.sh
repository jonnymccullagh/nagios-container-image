#!/bin/bash

/usr/sbin/nagios4 /etc/nagios4/nagios.cfg &
/usr/sbin/apachectl start & 
tail -f /dev/null
