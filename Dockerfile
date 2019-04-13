FROM alpine:latest

RUN apk update \
    && apk add \
    tar \
    perl

COPY startup-root.sh /root/startup-root.sh
COPY backup.pl /root/backup.pl
COPY crontab /root/crontab

RUN perl -c /root/backup.pl

RUN mkdir -p /backup/monthly \
    ; mkdir -p /backup/weekly \
    ; mkdir -p /backup/out
#    ; crontab /root/crontab

COPY crontab /etc/crontabs/root

ENTRYPOINT ["sh", "/root/startup-root.sh"]

CMD ["crond", "-f", "-d", "8", "> /proc/1/fd/1", "2> /proc/1/fd/2"]
