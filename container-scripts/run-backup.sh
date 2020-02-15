#!/bin/bash

if [ -d /backup/in ] && [ -d /backup/in_subdir ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --indir=/backup/in --insubdir=/backup/in_subdir --outdir=/backup/out --timeframe=$USER_ENV_TIMEFRAME
    if [ -d /backup/archive ]; then
        python $HOME/cleanup-backup.py /backup/out /backup/archive $USER_ENV_DAYS_TO_KEEP_ARCHIVE
    else
        echo "WARNING: config or archive directory not defined, automatic cleanup disabled"
    fi
else
    echo "ERROR: Backup directories were not defined"
fi
