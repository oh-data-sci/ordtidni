export SPARK_JAVA_OPTS="-Xmx16g"

JARS=/home/hadoop/jars/spark-xml_2.11-0.5.0.jar,/usr/lib/hadoop-lzo/lib/hadoop-lzo.jar

#--packages com.amazonaws:aws-java-sdk:1.7.4,org.apache.hadoop:hadoop-aws:2.7.3 \
spark-submit \
--conf spark.hadoop.fs.s3.awsAccessKeyId=C$AWS_ACCESS_KEY_ID \
--conf spark.hadoop.fs.s3.awsSecretAccessKey=$AWS_SECRET_ACCESS_KEY \
--conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
--master yarn  --class XMLScraper --name XMLScraper_App \
--jars $JARS \
/home/hadoop/jars/scalaspark_2.11-0.1.jar $*
