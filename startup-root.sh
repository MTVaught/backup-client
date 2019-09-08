#!/bin/sh

su -c /home/$MY_USER/run-dry.sh $MY_USER

exec "$@"
