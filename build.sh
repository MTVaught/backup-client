#!/bin/bash

docker pull centos:centos7
docker build --rm --tag=backup-client .
