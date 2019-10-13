#!/bin/sh

mkdir -p /backup/in /backup/in_subdir /backup/out

su -c /home/$MY_USER/run-dry.sh $MY_USER

exec "$@"
