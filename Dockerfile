FROM mtvaught/cron-base:latest

RUN apk update \
    && apk add \
        tar \
        perl

COPY startup-root.sh /root/staging/startup.sh
COPY backup.pl /root/staging/backup.pl
COPY run-backup.sh /root/staging/run.sh
COPY run-dry.sh /root/staging/run-dry.sh

RUN chmod +x /root/staging/startup.sh
RUN chmod +x /root/staging/run.sh
RUN chmod +x /root/staging/run-dry.sh

RUN sh -n /root/staging/startup.sh
RUN sh -n /root/staging/run.sh
RUN sh -n /root/staging/run-dry.sh
RUN perl -c /root/staging/backup.pl

RUN mkdir -p /backup/in

#CMD ["su", "-c", "bash", "-l", "user"];
