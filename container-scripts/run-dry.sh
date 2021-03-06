#!/bin/sh

if [ -d /backup/in ] && [ -d /backup/in_subdir ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --indir=/backup/in --insubdir=/backup/in_subdir --outdir=/backup/out --dryrun
else
    echo "ERROR: Directories were not defined"
fi
