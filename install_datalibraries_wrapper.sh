#!/bin/bash

# start Galaxy
#sed -i 's/#allow_library_path_paste = False/allow_library_path_paste = True/g' /etc/galaxy/galaxy.ini
service postgresql start
install_log='galaxy_install.log'

STATUS=$(psql 2>&1)   
while [[ ${STATUS} =~ "starting up" ]]
do
  echo "waiting for database: $STATUS"
  STATUS=$(psql 2>&1)  
  sleep 1
done

echo "starting Galaxy"
sudo -E -u galaxy ./run.sh --daemon --log-file=$install_log --pid-file=galaxy_install.pid

galaxy_install_pid=`cat galaxy_install.pid`

while : ; do
    tail -n 2 $install_log | grep -E -q "Removing PID file galaxy_install.pid|Daemon is already running"
    if [ $? -eq 0 ] ; then
        echo "Galaxy could not be started."
        echo "More information about this failure may be found in the following log snippet from galaxy_install.log:"
        echo "========================================"
        tail -n 60 $install_log
        echo "========================================"
        echo $1
        exit 1
    fi
    tail -n 2 $install_log | grep -q "Starting server in PID $galaxy_install_pid"
    if [ $? -eq 0 ] ; then
        echo "Galaxy is running."
        psql -lqt | cut -d \| -f 1 | grep -w galaxy | wc -l
        break
    fi
done

# upload data libraries
sleep 10
echo "installing data libraries"
python /home/galaxy/EMCtraining/installscripts/libuploadgalaxy.py

# stop everything
sudo -E -u galaxy ./run.sh --stop-daemon --log-file=$install_log --pid-file=galaxy_install.pid
rm $install_log
service postgresql stop