#!/bin/bash

mkdir -p test/monthly
mkdir -p test/weekly
mkdir -p test/backup

docker run -it --rm \
    --mount src=$PWD/test/monthly,target=/backup/monthly,type=bind,readonly \
    --mount src=$PWD/test/weekly,target=/backup/weekly,type=bind,readonly \
    --mount src=$PWD/test/backup,target=/backup/out,type=bind \
   backup-client 

    #-p 80:80 \
