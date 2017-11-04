#! /bin/sh
# /etc/init.d/delay.sh 

### BEGIN INIT INFO
# Provides:          random audio delay
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start a program at boot
# Description:       A simple script that will start / stop a program a boot / shutdown.
### END INIT INFO

# If you want a command to always run, put it here

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting Audio Delay Button"
    # run application you want to start
    python /home/pi/button.py
    ;;
  stop)
esac

exit 0
