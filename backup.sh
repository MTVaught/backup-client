#!/bin/bash

export DATA_DIR=/data
export TMP_DIR=/tmp

tar cvzf $TMP_DIR/backup.tar.gz $DATA_DIR 
