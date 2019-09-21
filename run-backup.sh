#!/bin/bash

if [ -d /backup/in ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --rootdir=/backup/in --outdir=/backup/out
    if [ -d /backup/config ]; then
        python $HOME/cleanup-backup.py /backup/out /backup/config/config.ini
    else
        echo "WARNING: config directory not defined, automatic cleanup disabled"
    fi
else
    echo "ERROR: Backup directories were not defined"
fi
