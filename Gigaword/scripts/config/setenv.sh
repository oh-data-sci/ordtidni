
# Where do we find the raw input XML?
export XML_DATA=~/Data/Gigaword/Data

# Where to write the processed parquet files to?
export OUTPUTDIR=~/Data/Gigaword/output2022

# What is the limit of a single glob of files to read in one go, before trying to process one sub-dir at a time?
# 1GB
#MEGABYTE_LIMIT=1024
# 8GB
#MEGABYTE_LIMIT=8192
# 10GB
MEGABYTE_LIMIT=10240
# 30GB
#MEGABYTE_LIMIT=30720

# We need one file to derive the XML schema from. This gets copied to /tmp/schema.xml ¯\_(ツ)_/¯ 
SCHEMA=${XML_DATA}/Appeal/2021/IGC-Adjud2_landsrettur_9_2021.ana.xml

# Set some SPARK variables
export SPARK_MASTER_HOST=192.168.0.132
export SPARK_LOCAL_IP=127.0.0.1
export SPARK_JAVA_OPTS="-Xmx16g"

# This files gets created oif I manually run `sbt package`
# TODO Make this as a 'release artifact' in Github.com ?
SCRAPE_JAR=../target/scala-2.12/ordtidnixml_2.12-0.1.jar

# RunAll.sh will try and process all the XML it gets fed.
# set this to YES (or any other value) if you wish to stop the loop processing of the XML input files, with a bit of grace ...
BREAK_NOW=NO
