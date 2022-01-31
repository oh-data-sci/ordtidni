#!/usr/bin/env bash
#config file that might have specific file locations that you might want to change
source ./config/variables.properties

#I hardcoded the XML schema file needed, to /tmp/schema.xml - but it keeps getting deleted :P
cp ${XML_DATA}/mbl/2019/06/G-15-6951994.xml /tmp/schema.xml

if [ "$BREAK_NOW" = "NO" ]; then
	echo "Still going"
	echo "change config/variables.properties set BREAK_NOW=YES if you want to stop this loop"
else
	exit 0
fi

export SPARK_JAVA_OPTS="-Xmx16g"

spark-submit \
--packages com.databricks:spark-xml_2.12:0.14.0 \
--master local[8] --executor-memory 4G --class XMLScraper --name XMLScraper_App \
$SCRAPE_JAR $*
