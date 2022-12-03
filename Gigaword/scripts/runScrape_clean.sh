#!/usr/bin/env bash

XML_DATA=~/Downloads/Gigaword/Data

#I hardcoded the XML schema file needed, to /tmp/schema.xml - but it keeps getting deleted :P

cp ${XML_DATA}/mbl/2019/06/G-15-6951994.xml /tmp/schema.xml



# This files gets created if I manually run `sbt package`

SCRAPE_JAR=/Users/borkur/Git/oh-data-sci/ordtidni/WordCount/target/scala-2.12/ordtidnixml_2.12-0.1.jar

# this file gets built with IntelliJ
# SCRAPE_JAR=$JR/OrdtidniXML.jar


export SPARK_JAVA_OPTS="-Xmx16g"

spark-submit \
--packages com.databricks:spark-xml_2.12:0.14.0 \
--master local[8] --executor-memory 4G --class XMLScraper --name XMLScraper_App \
$SCRAPE_JAR $*
