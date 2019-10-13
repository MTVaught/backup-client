FROM mtvaught/cron-base:latest

RUN apk update \
    && apk add \
        tar \
        perl \
        python \
        py-pip \
    && pip install \
        configparser

COPY container-scripts/startup.sh     /root/staging/startup.sh
COPY container-scripts/run-backup.sh  /root/staging/run.sh
COPY container-scripts/run-dry.sh     /root/staging/run-dry.sh
COPY backup-scripts/backup.pl         /root/staging/backup.pl
COPY backup-scripts/cleanup-backup.py /root/staging/cleanup-backup.py

RUN chmod +x /root/staging/startup.sh
RUN chmod +x /root/staging/run.sh
RUN chmod +x /root/staging/run-dry.sh
RUN chmod +x /root/staging/cleanup-backup.py

RUN sh -n /root/staging/startup.sh
RUN sh -n /root/staging/run.sh
RUN sh -n /root/staging/run-dry.sh
RUN perl -c /root/staging/backup.pl
RUN python -m py_compile /root/staging/cleanup-backup.py

RUN mkdir -p /backup/in
RUN mkdir -p /backup/in_subdir

#CMD ["su", "-c", "bash", "-l", "user"];
