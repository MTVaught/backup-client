#!/bin/sh

mkdir -p /backup/out/monthly
mkdir -p /backup/out/weekly 


echo "Weekly Backups:"
perl /root/backup.pl --rootdir=/backup/weekly --outdir=/backup/out/weekly --dryrun
echo "Monthly Backups:"
perl /root/backup.pl --rootdir=/backup/monthly --outdir=/backup/out/monthly --dryrun

exec "$@"
