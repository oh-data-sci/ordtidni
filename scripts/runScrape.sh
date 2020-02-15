#!/usr/bin/env bash


# Script to start the XML scraper on EC2. 

#AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY env vars must be set

# Some files are expected to be in place already in the jar_files directory
## aws-java-sdk-bundle-1.11.271.jar  hadoop-common-3.1.2.jar  ordtidnixml_2.11-0.1.jar
## hadoop-aws-3.1.2.jar              hadoop-lzo.jar           spark-xml_2.11-0.5.0.jar

#Where I've placed the various JAR files to get all of this to work :/
JR=/home/ec2-user/jar_files


# This files gets created if I manually run `sbt package`
SCRAPE_JAR=$JR/ordtidnixml_2.11-0.1.jar

JARS=$JR/hadoop-aws-3.1.2.jar,$JR/spark-xml_2.11-0.5.0.jar,$JR/hadoop-lzo.jar,$JR/hadoop-common-3.1.2.jar,$JR/aws-java-sdk-bundle-1.11.271.jar

# The below bundle of spark2.4 and hadopp 3.2 seems to work.
PATH=/home/ec2-user/spark-2.4.0-bin-custom-spark-2.4.0-hadoop-3.2/bin:$PATH
export SPARK_JAVA_OPTS="-Xmx12g"


spark-submit \
--conf spark.hadoop.fs.s3.awsAccessKeyId=C$AWS_ACCESS_KEY_ID \
--conf spark.hadoop.fs.s3.awsSecretAccessKey=$AWS_SECRET_ACCESS_KEY \
--conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
--conf spark.jars=$JARS \
--conf spark.executor.heartbeatInterval=30 \
--jars $JARS \
--master local[4] --driver-memory 4G --executor-memory 10G --class XMLScraper --name XMLScraper_App \
$SCRAPE_JAR $*
