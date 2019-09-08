#!/bin/bash

mkdir -p test/in
mkdir -p test/out

docker run --rm \
    -v $PWD/test/in:/backup/in:Z \
    -v $PWD/test/out:/backup/out:Z \
    --env APP_UID=`id -u` \
    --env APP_GID=`id -g` \
    --env APP_CRON='* * * * *' \
   backup-client &
