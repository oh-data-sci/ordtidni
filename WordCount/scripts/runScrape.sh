:

export SPARK_JAVA_OPTS="-Xmx16g" 

JARS=/Users/borkur/Downloads/Gigaword/jar_files/hadoop-aws-3.2.0.jar,/Users/borkur/Downloads/Gigaword/jar_files/aws-java-sdk-bundle-1.11.375.jar,/Users/borkur/Documents/GIT/databricks/spark-xml/target/scala-2.11/spark-xml_2.11-0.5.0.jar

--conf "spark.driver.extraClassPath=/Users/borkur/Downloads/Gigaword/jar_files/aws-java-sdk-bundle-1.11.375.jar" \
--conf "spark.driver.extraClassPath=/Users/borkur/Downloads/Gigaword/jar_files/hadoop-aws-3.2.0.jar" \

spark-submit \
--packages com.amazonaws:aws-java-sdk:1.7.4,org.apache.hadoop:hadoop-aws:2.7.3 \
--conf spark.hadoop.fs.s3.awsAccessKeyId=C$AWS_ACCESS_KEY_ID \
--conf spark.hadoop.fs.s3.awsSecretAccessKey=$AWS_SECRET_ACCESS_KEY \
--conf spark.hadoop.fs.s3.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
--conf spark.driver.extraClassPath=/Users/borkur/Downloads/Gigaword/jar_files/aws-java-sdk-bundle-1.11.375.jar \
--conf spark.driver.extraClassPath=/Users/borkur/Downloads/Gigaword/jar_files/hadoop-aws-3.2.0.jar \
--master local --executor-memory 12G --class XMLScraper --name XMLScraper_App \
--jars $JARS \
/Users/borkur/Documents/GIT/oh-data-sci/ordtidni/WordCount/target/scala-2.11/scalaspark_2.11-0.1.jar
