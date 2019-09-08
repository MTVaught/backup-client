#!/bin/bash

if [ -d /backup/in ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --rootdir=/backup/in --outdir=/backup/out
else
    echo "ERROR: Directories were not defined"
fi
