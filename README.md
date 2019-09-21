# backup-client

A docker container that will automatically generate tar files from directories.

# ENV variables
See https://github.com/MTVaught/docker-cron-base for ENV variables

# Directory mounts

    /backup/config (ro)
    /backup/in (ro)
    /backup/out (rw)

# /backup/config
Optional. Required to enable automatic cleanup of tars.
In order to enable, must contain config.ini with:

    [CLEANUP]
    days = <number>

# /backup/in
Any file/directory in this directory will have a tar created for it.

# /backup/out
The tars created will be placed in here.
