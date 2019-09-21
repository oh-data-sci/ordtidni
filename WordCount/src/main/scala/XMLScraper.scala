//import org.apache.spark.sql.{SparkSession, functions}
import org.apache.spark.sql._
import com.databricks.spark.xml._
import org.apache.hadoop.fs._
import org.apache.spark.sql.streaming.{OutputMode, Trigger}
import org.apache.spark.sql.types.{StringType, StructField, StructType}
import org.apache.hadoop.io.{LongWritable, Text}
import com.databricks.spark.xml.XmlInputFormat



object XMLScraper {
  def main(args: Array[String]) {

    val n = args.length

    val usage = "Usage: XMLScraper  [--source Source String] [--year Year num] " +
      "[--month Month num] " +
      "e.g. MIM mbl 2015 10"

    if(n < 4)
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

    val l_options = nextOption(Map(),arglist)
    println(l_options)
   // var l_ds = l_options('dataset)
    //println(l_ds)
    val l_source = l_options('source)
    println(l_source)
    var l_year = l_options('year)
    println(l_year)
    var l_month = l_options('month)
    println(l_month)
    //throw new Exception ("going home  "+ arglist.toStream)

    if(l_year == "x")
      l_year="*"

    if(l_month == "x")
      l_month="*"


//    val sc = SparkSession.builder.master("local").appName("XMLScraper").getOrCreate()
    val sc = SparkSession.builder.getOrCreate()



    //val xml = sc.fileStream[LongWritable,Text,XmlInputFormat](monitoredDirectory,true,false)

//    var l_inputString  = "s3a://ordtidni/XML/" + l_ds + "/" +  l_source + "/" +l_year
//    var l_outputString = "s3a://ordtidni/output/" + l_ds + "/" +  l_source + "/" +l_year

    val l_inputString  = "s3a://ordtidni/XML/" +  l_source + "/" +l_year + "/" +l_month
//    val l_outputString = "s3a://ordtidni/output/" + l_source + "/" //+l_year + "/" +l_month
//    val l_inputString = "/Users/borkur/Downloads/"

//    var l_inputString = "/Users/borkur/Downloads/Arnastofnun/" + l_ds + "/" +  l_source + "/" +l_year
    var l_outputString = "/tmp/" + "/" +  l_source + "/" +l_year

    println("Input:  "+l_inputString)
    println("Output: "+l_outputString)

    // TODO This is perhaps better done with Spark Streaming ?
    // TODO handle dataset, source, year and month. Still think Spark Streaming is what we need

    val giga_schema = sc.read
      .format("com.databricks.spark.xml")
      .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
      .xml("/tmp/schema.xml")
      .schema //Get the schema from a single XML example on HDFS to use for the bulk

    val df = sc.read
      .format("com.databricks.spark.xml")
      .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
      .schema(giga_schema) //This saved 10 minutes over 43.000 files. fro 10m to 0.4 s for this step. (morgunbladid/2015). Using one XML file as the schema to avoid schema discovery each time
      .xml(l_inputString+"/*.xml") // Given dataset, source and year: add all months and all XML files
      .withColumn("Word",functions.explode(functions.col("w"))) // Flatten out
      .select("Word._lemma","Word._type","Word._VALUE")
      .toDF("Lemma","POS","Word") // Just the columns we want.

//      val fileStreamDf = sc.readStream
//        .format("com.databricks.spark.xml")
//          .format("xml")
//        .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
//        .schema(giga_schema) //This saved 10 minutes over 43.000 files. fro 10m to 0.4 s for this step. (morgunbladid/2015)
//        .load(l_inputString+"/*/*.xml") // Given dataset, source and year: add all months and all XML files
//        .withColumn("Word",functions.explode(functions.col("w"))) // Flatten out
//        .select("Word._lemma","Word._type","Word._VALUE")
//        .toDF("Lemma","POS","Word") // Just the columns we want.

//
//    df.coalesce(1)
    ////      .write
    ////      .format("com.databricks.spark.csv")
    ////      .option("header", "false")
    //////      .mode("overwrite")
    ////      .mode("append")
    ////      .save(l_outputString) // save to S3


    df.coalesce(20)
      .write
      .format("parquet")
      //.option("header", "false")
      //      .mode("overwrite")
      .mode("append")
      .save(l_outputString) // save to S3


//    val query = fileStreamDf.writeStream
//      .format("com.databricks.spark.csv")
//      .option("header", "false")
//      .outputMode(OutputMode.Append())
//      .option("path",l_outputString) // save to S3
//      .start()
//
//    query.awaitTermination()


  }
}
