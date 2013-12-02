#!/bin/sh

# configs
BACKUP_SOURCE_DIR= # website dir (something like /var/www/)
BACKUP_DB_HOST="" # database host (somethig like "localhost")
BACKUP_DB_USER="" # datase user 
BACKUP_DB_PASS="" # database password
AMAZON_S3_USER="" # amazon s3 id (found on http://j.mp/1aoolBs)
AMAZON_S3_KEY="" # amazon s3 key (found on http://j.mp/1aoolBs)
AMAZON_S3_BUCKET="`hostname`" # amazon bucket name to be created (default server hostname)


# from now on, DO NOT CHANGE
TIMESTAMP=$(date +"%F")
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

BACKUP_DESTINATION_DIR=~/backup/$TIMESTAMP/
BACKUP_DESTINATION_DIR_MYSQL=$BACKUP_DESTINATION_DIRmysql/


# check if destination dir exists
check_destination_dir() {
    if [ ! -d $BACKUP_DESTINATION_DIR ]; then
    	echo "$BACKUP_DESTINATION_DIR"
        mkdir -p $BACKUP_DESTINATION_DIR
        echo "$BACKUP_DESTINATION_DIR_MYSQL"
        mkdir -p $BACKUP_DESTINATION_DIR_MYSQL
    fi
}

# dump all databases
dump_databases() {
	databases=`$MYSQL --user=$BACKUP_DB_USER -p$BACKUP_DB_PASS -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|phpmyadmin)"`
 
	for db in $databases; do
		echo "Dumping database $db"
  		$MYSQLDUMP --force --lock-all-tables --routines --triggers --events --user=$BACKUP_DB_USER -p$BACKUP_DB_PASS --databases $db | gzip > "$BACKUP_DESTINATION_DIR_MYSQL$db.gz"
	done
}

# create a compressed tar.gz file of each folder (website)
backup_projects() {
	for i in $(ls -d $BACKUP_SOURCE_DIR*/); do 

		FOLDER=$(basename $i)
		echo "Compressing $BACKUP_DESTINATION_DIR$FOLDER.tar.gz $i"
		tar -czPf "$BACKUP_DESTINATION_DIR$FOLDER.tar.gz" $i
	done	
}

# create a huge zip with the complete backup including files and databases to send to Amazon S3
compress_all() {
	FOLDER="$(dirname $0)"
	tar -czPf "$FOLDER/$TIMESTAMP.tar.gz" $BACKUP_DESTINATION_DIR
	rm -rf $BACKUP_DESTINATION_DIR
}

# call a php file to make the upload to Amazon S3
upload_files() {
	compress_all
	FOLDER="$(dirname $0)"
	TAR="$FOLDER/$TIMESTAMP.tar.gz"
	SIZE="$(du -sh $TAR)"

	echo "Uploading $SIZE to amazon server"
	php $FOLDER/upload.php $AMAZON_S3_USER $AMAZON_S3_KEY $AMAZON_S3_BUCKET $TAR

}


# let's rock and roll (call the funcions in order and display some feedback)
echo "Checking/creating directories"
check_destination_dir
echo "Dumping databases"
dump_databases
echo "Backup projects"
backup_projects
echo "Uploading files"
upload_files



