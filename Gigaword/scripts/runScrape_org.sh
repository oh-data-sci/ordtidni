#!/usr/bin/env bash


#I hardcoded the XML schema file needed, to /tmp/schema.xml - but it keeps getting deleted :P

cp ~/Downloads/Gigaword/Data/mbl/2019/06/G-15-6951994.xml /tmp/schema.xml

# Here we use Oskar's supplied custom spark 2.4
#PATH=/Users/borkur/opt/spark/spark-2.4.0-bin-custom-spark-2.4.0-hadoop-3.2/bin:$PATH

export SPARK_JAVA_OPTS="-Xmx16g"
#Where I've placed the various JAR files to get all of this to work :/
JR=/Users/borkur/opt/jar_files

# This files gets created if I manually run `sbt package`
#SCRAPE_JAR=/Users/borkur/Git/oh-data-sci/ordtidni/WordCount/target/scala-2.11/ordtidnixml_2.11-0.1.jar
SCRAPE_JAR=/Users/borkur/Git/oh-data-sci/ordtidni/WordCount/target/scala-2.12/ordtidnixml_2.12-0.1.jar
# this file gets built with IntelliJ
# SCRAPE_JAR=$JR/OrdtidniXML.jar

#JARS=$JR/hadoop-aws-3.1.2.jar,$JR/spark-xml_2.11-0.5.0.jar,$JR/hadoop-lzo.jar,$JR/hadoop-common-3.1.2.jar,$JR/aws-java-sdk-bundle-1.11.271.jar,$JR/OrdtidniXML.jar
JARS=$JR/spark-xml_2.11-0.5.0.jar,$JR/hadoop-lzo.jar,$JR/hadoop-common-3.1.2.jar,$JR/aws-java-sdk-bundle-1.11.271.jar

#--conf spark.driver.extraClassPath=$JR/aws-java-sdk-s3-1.11.595.jar \
#--conf spark.driver.extraClassPath=$JR/hadoop-aws-3.1.2.jar \
#--conf spark.driver.extraClassPath=$JR/spark-xml_2.11-0.5.0.jar \
#--conf spark.jars=$JARS \
#--jars $JARS \

#--packages com.amazonaws:aws-java-sdk:1.7.4,org.apache.hadoop:hadoop-aws:2.7.3 \
#--packages com.amazonaws:aws-java-sdk-s3:1.11.594,org.apache.hadoop:hadoop-aws:3.1.2,com.databricks:spark-xml_2.11:0.5.0 \
#--conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \

#--conf spark.hadoop.fs.s3.awsAccessKeyId=C$AWS_ACCESS_KEY_ID \
#--conf spark.hadoop.fs.s3.awsSecretAccessKey=$AWS_SECRET_ACCESS_KEY \
#--conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
#--conf spark.jars=$JARS \
#--jars $JARS \

spark-submit \
--packages com.databricks:spark-xml_2.12:0.14.0 \
--master local[8] --executor-memory 4G --class XMLScraper --name XMLScraper_App \
$SCRAPE_JAR $*
