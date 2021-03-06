#!/usr/bin/env bash

BACKUP_SCRIPT='ec2-automate-backup.sh'

die() {
  >&2 echo "$@"
  exit 1
}

vars=(
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  INSTANCE_ID
  REGION
)

cmds=(
  wget
  jq
  aws
  $BACKUP_SCRIPT
)

# check that all required cli programs are present
for c in ${cmds[*]}
do
  if ! hash "$c" 2>/dev/null; then
    die "prog: $c is required"
  fi
done

# lookup ec2 instance-id
INSTANCE_ID=${INSTANCE_ID:-$(wget -q -O- 'http://169.254.169.254/latest/meta-data/instance-id')}

# lookup ec2 region
REGION=${REGION:-$(wget -q -O- 'http://169.254.169.254/latest/dynamic/instance-identity/document' | jq --raw-output '.region')}

# check that all required env vars are declared
for v in ${vars[*]}
do
  # it doesn't seem to be possible to check for undefined variables via
  # indirection in bash, the best we can do is check for empty string (which
  # shouldn't be a problem in this case as an empty string can't be used with
  # the aws cli)
  if [[ -z ${!v} ]]; then
    die "env var $v is required"
  fi
done

# lookup volume-ids for our instance-id; assuming only one volume is mounted
VOLUME_ID="$(aws ec2 describe-volumes --region "$REGION" --filters Name=attachment.instance-id,Values="${INSTANCE_ID}" | jq --raw-output '.Volumes[0].VolumeId')"

# option snapshot our volume-id

# XXX for unknown reasons, ec2-automate-backup.sh defaults to EC2_REGION
# instead of AWS_DEFAULT_REGION -- so we are setting it an exclitly as a cli
# option
"$BACKUP_SCRIPT" -v "$VOLUME_ID" -r "$REGION" -k 91d -n -p

# vim: tabstop=2 shiftwidth=2 expandtab
