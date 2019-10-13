#!/bin/bash

if [ -d /backup/in ] && [ -d /backup/in_subdir ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --indir=/backup/in --insubdir=/backup/in_subdir --outdir=/backup/out
    if [ -d /backup/config ]; then
        python $HOME/cleanup-backup.py /backup/out /backup/config/config.ini
    else
        echo "WARNING: config directory not defined, automatic cleanup disabled"
    fi
else
    echo "ERROR: Backup directories were not defined"
fi
