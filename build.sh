#!/bin/bash

docker pull alpine:latest
docker build --rm --tag=backup-client .
