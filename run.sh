#!/bin/bash

mkdir -p test/in
mkdir -p test/in_subdir
mkdir -p test/out
mkdir -p test/archive

docker run --rm \
    -v $PWD/test/in:/backup/in:Z \
    -v $PWD/test/in_subdir:/backup/in_subdir:Z \
    -v $PWD/test/out:/backup/out:Z \
    -v $PWD/test/archive:/backup/archive:Z \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
    --env USER_ENV_TIMEFRAME='week' \
    --env APP_RUN_ON_STARTUP='true' \
    --env DEBUG='true' \
    --env USER_ENV_DAYS_TO_KEEP_ARCHIVE='30' \
   backup-client &

