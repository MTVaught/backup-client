# backup-client

# ENV variables
(currently none)
USE_ENCRYPTION=<0|1>
USE_VERBOSE=<0|1>

# BIND mounts:
backup sources are located in:
    /backup/monthly
    /backup/weekly
backup outputs are in
    /backup/out/monthly
    /backup/out/weekly

If I wanted to back up "/home/user/importantfiles":
bind (readonly) /home/user/importantfiles -> /backup/weekly/importantfiles
or
bind (readonly) /home/user/importantfiles -> /backup/monthly/importantfiles

