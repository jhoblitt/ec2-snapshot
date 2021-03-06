FROM docker.io/lsstsqre/awscli:latest

ARG BACKUP_SCRIPT_URL='https://raw.githubusercontent.com/lsst-sqre/aws-missing-tools/1b6cd230dde529f3bf4c19ea80fccdf42e479dae/ec2-automate-backup/ec2-automate-backup.sh'
ARG BACKUP_SCRIPT='/usr/local/bin/ec2-automate-backup.sh'
ARG RUN_SCRIPT='/usr/local/bin/ec2-snapshot.sh'

RUN apk add --no-cache --update bash wget ca-certificates jq && \
    rm -rf /root/.cache

RUN wget --no-verbose "$BACKUP_SCRIPT_URL" -O "$BACKUP_SCRIPT" && \
    chmod a+x "$BACKUP_SCRIPT"

COPY ec2-snapshot.sh "$RUN_SCRIPT"
RUN chmod a+x "$RUN_SCRIPT"
