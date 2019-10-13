#!/bin/sh

if [ -d /backup/in ] && [ -d /backup/out ]; then
    perl $HOME/backup.pl --rootdir=/backup/in --outdir=/backup/out --dryrun
else
    echo "ERROR: Directories were not defined"
fi
