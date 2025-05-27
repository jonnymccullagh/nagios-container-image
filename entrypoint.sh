#!/bin/bash

# Remove the Apache PID file if it exists
if [[ -f /var/run/apache2/apache2.pid ]]; then
    rm /var/run/apache2/apache2.pid
fi

# Start Nagios
/usr/sbin/nagios4 /etc/nagios4/nagios.cfg &

# Start Apache
/usr/sbin/apachectl start &

# Keep the container running
tail -f /dev/null