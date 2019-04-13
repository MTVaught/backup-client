#!/bin/sh

mkdir -p /backup/out/monthly
mkdir -p /backup/out/weekly 

exec "$@"
