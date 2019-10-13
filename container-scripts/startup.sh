#!/bin/sh

su -c /home/$MY_USER/run-dry.sh $MY_USER

su -c "mkdir -p /backup/in /backup/in_subdir /backup/out" $MY_USER

exec "$@"
