Server-Backup
=============

A server backup script that send files to Amazon S3


This script uses the S3 uploader from https://github.com/tpyo/amazon-s3-php-class


To use this backup script just fill the configs in backup.sh


# configs
```sh
BACKUP_SOURCE_DIR= # website dir (something like /var/www/)
BACKUP_DB_HOST="" # database host (somethig like "localhost")
BACKUP_DB_USER="" # datase user 
BACKUP_DB_PASS="" # database password
AMAZON_S3_USER="" # amazon s3 id (found on http://j.mp/1aoolBs)
AMAZON_S3_KEY="" # amazon s3 key (found on http://j.mp/1aoolBs)
AMAZON_S3_BUCKET="`hostname`" # amazon bucket name to be created (default server hostname)
```

tip: put this in your crontab to execute daily at 2 am
crontab -e
0 2 * * * . /PATH_TO/backup.sh

thanks
