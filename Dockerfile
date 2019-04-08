FROM centos:centos7

RUN yum install -y \
    vim-minimal

COPY startup-root.sh /root/startup-root.sh
COPY backup.sh /root/backup.sh

CMD ["bash", "/root/startup-root.sh"]
