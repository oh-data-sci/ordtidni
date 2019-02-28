:
export HADOOP_CONF_DIR=/usr/local/Cellar/hadoop/3.1.1/libexec/etc/hadoop

PATH=/Users/borkur/Downloads/Software/Hadoop/hadoop-2.6.0/bin:/Users/borkur/Downloads/Software/Hadoop/spark-2.4.0-bin-hadoop2.6/bin:$PATH


hadoop fs -rm -r -f /tmp/shakespeareWordCount

#spark-submit --master yarn-cluster --class WordCount --name WordCount_Application --deploy-mode client /Users/borkur/Documents/GIT/borkur/ScalaSpark/target/scala-2.11/scalaspark_2.11-0.1.jar $*
spark-submit --master spark://quickstart.cloudera:8032 --class WordCount --name WordCount_Application --deploy-mode client /Users/borkur/Documents/GIT/borkur/ScalaSpark/target/scala-2.11/scalaspark_2.11-0.1.jar $*
