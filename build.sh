#!/bin/bash

docker pull mtvaught/cron-base:latest
docker pull mtvaught/cron-base:user-env
docker build --rm --tag=backup-client .
