:

export SPARK_JAVA_OPTS="-Xmx16g" 
spark-submit --master local --executor-memory 12G --class XMLScraper --name XMLScraper_App --jars ~/Documents/GIT/databricks/spark-xml/target/scala-2.11/spark-xml_2.11-0.5.0.jar /Users/borkur/Documents/GIT/oh-data-sci/ordtidni/WordCount/target/scala-2.11/scalaspark_2.11-0.1.jar
