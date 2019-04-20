#!/bin/sh

mkdir -p /backup/out/monthly
mkdir -p /backup/out/weekly 
mkdir -p /backup/gpg/monthly
mkdir -p /backup/gpg/weekly


echo "Weekly Backups:"
perl /root/backup.pl --rootdir=/backup/weekly --outdir=/backup/out/weekly --dryrun
echo "Monthly Backups:"
perl /root/backup.pl --rootdir=/backup/monthly --outdir=/backup/out/monthly --dryrun

perl /root/backup.pl --rootdir=/backup/weekly --outdir=/backup/out/weekly --gpgoutdir=/backup/gpg/weekly --gpg_passphrase=\'$GPG_KEY\'



exec "$@"
