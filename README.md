# backup-client

A docker container that will automatically generate tar files from directories.

# ENV variables
See https://github.com/MTVaught/docker-cron-base for ENV variables

    USER_ENV_TIMEFRAME  : [quarter|month|week] - frequency to do level 0 backup
    USER_ENV_DAYS_TO_KEEP_ARCHIVE : <num_days> - number of days before moving backup into "archive" folder.
                                                 Measures from the last day of a backup period.

# Directory mounts

    /backup/in (ro)         : Tars will be made of all files/directories listed in this dir
    /backup/in_subdir (ro)  : Tars all subdirs of all directories listed here.
    /backup/out (rw)        : Directory to save tars into
    /backup/archive (rw)    : Directory to move tars into once they are older than $USER_ENV_DAYS_TO_KEEP_ARCHIVE
