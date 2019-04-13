FROM centos:centos7

RUN yum install -y \
    vim-minimal \
    crontabs \
    tar \
    perl

COPY startup-root.sh /root/startup-root.sh
COPY backup.pl /root/backup.pl
COPY crontab /root/crontab

RUN mkdir -p /backup/monthly \
    ; mkdir -p /backup/weekly \
    ; mkdir -p /backup/out \
    ; crontab /root/crontab

CMD ["bash", "/root/startup-root.sh"]
