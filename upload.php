<?php

# set the detault timezone (you can change it if you want)
date_default_timezone_set('America/Sao_Paulo');

# include the s3.php file (from https://github.com/tpyo/amazon-s3-php-class)
require_once 's3.php';

// Create a new instance of S3 with the cli arguments
$s3 = new S3($argv[1], $argv[2]);

// create a lower case bucket name without space
$bucketName = strtolower('server-'.preg_replace('/[^A-Za-z0-9-]+/', '-', $argv[3]));
$uploadFile = $argv[4];

// Create a bucket with public read access
if ($s3->putBucket($bucketName, S3::ACL_PUBLIC_READ)) {
    echo "Created bucket {$bucketName}".PHP_EOL;

    // Put our file (also with public read access)
    if ($s3->putObjectFile($uploadFile, $bucketName, baseName($uploadFile), S3::ACL_PUBLIC_READ)) {
    	echo "S3::putObjectFile(): File copied to {$bucketName}/".baseName($uploadFile).PHP_EOL;
		
		// Get the contents of our bucket
        $contents = $s3->getBucket($bucketName);
        echo "S3::getBucket(): Files in bucket {$bucketName}: ".print_r($contents, 1);

        // Get object info
        $info = $s3->getObjectInfo($bucketName, baseName($uploadFile));
        echo "S3::getObjectInfo(): Info for {$bucketName}/".baseName($uploadFile).': '.print_r($info, 1);

        // Delete file
        unlink($uploadFile);
    }
}
