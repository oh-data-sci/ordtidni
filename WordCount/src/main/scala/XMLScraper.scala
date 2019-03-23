//import org.apache.spark.sql.{SparkSession, functions}
import org.apache.spark.sql._
import com.databricks.spark.xml._
import org.apache.hadoop.fs._
//import com.amazonaws.

object XMLScraper {
  def main(args: Array[String]) {

    val n = args.length

    val usage = "Usage: XMLScraper --dataset Dataset  [--source Source String] [--year Year num] " +
      //+"[--month Month num] " +
      "e.g. MIM mbl 2015 10"

    if(n < 6)
      throw new Exception ("Must provide dataset, source and year to read from: "+ usage)

    val arglist = args.toList

    //if(n == 6)
    //  throw new Exception ("Good job: "+ arglist.toStream)

    type OptionMap = Map[Symbol, Any]
    def nextOption(map : OptionMap, list: List[String]) : OptionMap = {
      def isSwitch(s : String) = (s(0) == '-')
      list match {
        case Nil => map
        case "--dataset" :: value :: tail =>
          nextOption(map ++ Map('dataset -> value.toString), tail)
        case "--source" :: value :: tail =>
          nextOption(map ++ Map('source -> value.toString), tail)
        case "--year" :: value :: tail =>
          nextOption(map ++ Map('year -> value.toString), tail)
        case "--month" :: value :: tail =>
          nextOption(map ++ Map('month -> value.toString), tail)
        case option :: tail => println("Unknown option "+option)
          throw new Exception ("Unknown options: "+ arglist.toStream)
      }
    }

    var l_options = nextOption(Map(),arglist)
    println(l_options)
    var l_ds = l_options('dataset)
    println(l_ds)
    var l_source = l_options('source)
    println(l_source)
    var l_year = l_options('year)
    println(l_year)
//    var Any l_month="*"
//    try {
//      l_month = l_options('month)
//    }
//    println(l_month)
    //throw new Exception ("going home  "+ arglist.toStream)


    //val sc = SparkSession.builder.master("local").appName("XMLScraper").getOrCreate()
    val sc = SparkSession.builder.getOrCreate()
    var l_inputString = "s3a://borkur-gigaword/XML/" + l_ds + "/" +  l_source + "/" +l_year

    //sc.hadoopConfiguration.set("fs.s3n.awsAccessKeyId", accessKeyId)
    //sc.hadoopConfiguration.set("fs.s3n.awsSecretAccessKey", secretAccessKey)

    // TODO This is perhaps better done with Spark Streaming ?
    // TODO handle dataset, source, year and month. Still think Spark Streaming is what we need
    val l_dataset = args
    val giga_schema = sc.read
      .format("com.databricks.spark.xml")
      .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
      .xml("/tmp/schema.xml").schema //Get the schema from a single XML example to use for the bulk

    val df = sc.read
      .format("com.databricks.spark.xml")
      .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
      .schema(giga_schema) //This saved 10 minutes over 43.000 files. fro 10m to 0.4 s for this step. (morgunbladid/2015)
      .xml(l_inputString+"/*/*.xml") // Given dataset, source and year: add all months and all XML files
      .withColumn("Word",functions.explode(functions.col("w"))) // Flatten out
      .select("Word._lemma","Word._type","Word._VALUE").toDF("Lemma","POS","Word") // Just the columns we want.
      //.repartition(600,functions.col("POS")) // Not convinced this is doing what I think it does. at least not getting one partition per POS

//    df.write
//        .format("com.databricks.spark.csv")
//        .option("header", "false")
//        .mode("overwrite")
//        .save("/tmp/scrape/") // save to HDFS

    df.coalesce(1)
      .write
      .format("com.databricks.spark.csv")
      .option("header", "false")
      //.mode("overwrite")
      .mode("append")
      .save("s3a://borkur-gigaword/output") // save to S3


  }
}
