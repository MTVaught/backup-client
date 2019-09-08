#!/bin/bash

docker pull mtvaught/cron-base:latest
docker build --rm --tag=backup-client .
