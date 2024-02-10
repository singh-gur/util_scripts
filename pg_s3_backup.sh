#!/bin/bash

#display and exit-on-error for all commands
set -e
set +v

echo "Postgres S3 Backup Script"

HOST=""
PORT="5432"
DBNAME="postgres"
USER="postgres"
PASSWORD=""
S3_BUCKET=""
S3_PREFIX=""
AWS_PROFILE="default"


usage()
{

cat << eof
usage: pg_s3_backup.sh [options]
--host,-h          Hostname of the postgres server
--port,-p          Port of the postgres server
--dbname,-d        Name of the database to backup
--user,-u          Username to connect to the database
--password,-w      Password to connect to the database
--s3-bucket,-b     S3 Bucket to upload the backup
--s3-prefix,-s     S3 Prefix to upload the backup
--aws-profile,-a   AWS Profile to use for the upload
eof
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --host )
            HOST=$(echo $VALUE | tr -d '"')
        ;;
        -p | --port )
            PORT=$(echo $VALUE | tr -d '"')
        ;;
        -d | --dbname )
            DBNAME=$(echo $VALUE | tr -d '"')
        ;;
        -u | --user )
            USER=$(echo $VALUE | tr -d '"')
        ;;
        -w | --password )
            PASSWORD=$(echo $VALUE | tr -d '"')
        ;;
        -b | --s3-bucket )
            S3_BUCKET=$(echo $VALUE | tr -d '"')
        ;;
        -s | --s3-prefix )
            S3_PREFIX=$(echo $VALUE | tr -d '"')
        ;;
        -a | --aws-profile )
            AWS_PROFILE=$(echo $VALUE | tr -d '"')
        ;;
        -h | --help )
            usage
            exit
    esac
    shift
done

YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY_WITH_TIME=$(date +%d_%H%M%S)

FILENAME="$DBNAME-$YEAR-$MONTH-$DAY_WITH_TIME.tar"
PGPASSWORD="$PASSWORD" pg_dump -h $HOST -p $PORT -U $USER -d $DBNAME -w -F t -b -v -f /tmp/$FILENAME
aws s3 cp /tmp/$FILENAME s3://$S3_BUCKET/$S3_PREFIX/$FILENAME --profile $AWS_PROFILE

