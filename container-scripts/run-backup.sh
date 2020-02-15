#!/bin/bash

if [ -d /backup/in ] && [ -d /backup/in_subdir ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --indir=/backup/in --insubdir=/backup/in_subdir --outdir=/backup/out --timeframe=$USER_ENV_TIMEFRAME
    if [ -d /backup/config ] && [ -d /backup/exclude ]; then
        python $HOME/cleanup-backup.py /backup/out /backup/exclude /backup/config/config.ini
    else
        echo "WARNING: config or exclude directory not defined, automatic cleanup disabled"
    fi
else
    echo "ERROR: Backup directories were not defined"
fi
