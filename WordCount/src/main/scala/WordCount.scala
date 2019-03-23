import org.apache.spark.sql.{SparkSession, functions}
import org.apache.spark.{SparkConf, SparkContext}


object WordCount {

  def main(args: Array[String]) {

    //Create a SparkContext to initialize Spark
    val conf = new SparkConf()


//    val arg1 = args(0)
//    println("Got argument: " + arg1)
//    conf.setMaster(spark_master)
    conf.setMaster("local")
    conf.setAppName("Gigaword")
//    conf.setMaster("yarn-cluster")
    //val sc = new SparkContext(conf)
    val sc = SparkSession.builder.getOrCreate()

    // Load the text into a Spark RDD, which is a distributed representation of each line of text
    //val textFile = sc.textFile("hdfs://quickstart.cloudera:8022/tmp/shakespeare.txt")
    //val textFile = sc.textFile("hdfs://borkur.synology.me/tmp/shakespeare.txt")

    //val textFile = sc.textFile("src/main/resources/shakespeare.txt")
    //val textFile = sc.textFile("/Users/borkur/Downloads/Gigaword/blob.txt.out")
    val df = sc.read
      .format("com.databricks.spark.csv")
      .csv("s3a://borkur-gigaword/output/") // This now runs in 11 min for a single year

    //TODO complete list of separators
    //val counts = textFile.flatMap(line => line.split("[ ,.:;!-?\\[\\]]"))
    //  .map(word => (word, 1))
    //  .reduceByKey(_ + _)

    //counts.map(x => x._1 + "," + x._2).saveAsTextFile("/tmp/shakespeareWordCount")
    //counts.map(x => x._1 + "," + x._2).saveAsTextFile("s3a://borkur-gigaword/wordcount")
  }

}