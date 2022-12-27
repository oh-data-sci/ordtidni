#!/usr/bin/env bash
#config file that might have specific file locations that you might want to change
source ./config/setenv.sh

#I hardcoded the XML schema file needed, to /tmp/schema.xml - but it keeps getting deleted :P
cp ${SCHEMA} /tmp/schema.xml

# 

spark-submit \
--packages com.databricks:spark-xml_2.12:0.14.0 \
--deploy-mode client \
--master spark://${SPARK_MASTER_HOST}:7077  \
--executor-memory 12GB --class XMLScraper --name XMLScraper_App_${2}_${4} \
$SCRAPE_JAR $*
ret=$?

sleep 5
exit $ret
