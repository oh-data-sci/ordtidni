//import org.apache.spark.sql.{SparkSession, functions}
import org.apache.spark.sql._
import com.databricks.spark.xml._

object XMLScraper {
  def main(args: Array[String]) {

    //val sc = SparkSession.builder.master("local").appName("XMLScraper").getOrCreate()
    val sc = SparkSession.builder.getOrCreate()

    // TODO read in from S3 - https://stackoverflow.com/questions/24029873/how-to-read-multiple-text-files-into-a-single-rdd
    // TODO Inferring schema for each file reading in. Get one schema and use that schema for all files might speed up reading -- https://www.dropbox.com/s/cb7ze5la0qkbywu/Screenshot%202019-03-19%2001.04.32.png?dl=1
    // TODO This is perhaps better done with Spark Streaming ?
    val giga_schema = sc.read
      .format("com.databricks.spark.xml")
      .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
      .xml("/Users/borkur/Downloads/Arnastofnun/MIM/morgunbladid/2016/8/G-32-4246658.xml").schema

    val df = sc.read
      .format("com.databricks.spark.xml")
      .option("rowTag", "s") // Only reading in 'S' = 'Sentence'
      .schema(giga_schema) //This saved 10 minutes over 43.000 files. fro 10m to 0.4 s for this step. (morgunbladid/2015)
      .xml("/Users/borkur/Downloads/Arnastofnun/MIM/morgunbladid/2015/*/*.xml") // This now runs in 11 min for a single year
      .withColumn("Word",functions.explode(functions.col("w"))) // Flatten out
      .select("Word._lemma","Word._type","Word._VALUE").toDF("Lemma","POS","Word") // Just the columns we want.
      .repartition(600,functions.col("POS")) // Not convinced this is doing what I think it does. at least not getting one partition per POS
      .write.format("com.databricks.spark.csv").option("header", "false").mode("overwrite").save("/tmp/scrape/") // save to disk



    //val flattened = df.withColumn("Word",functions.explode(functions.col("w"))) // Getting 'w' tags and flatten as 'Word' struct
    //flattened.printSchema()

    //val SelectedItems = flattened.select("Word._lemma","Word._type","Word._VALUE").toDF("Lemma","POS","Word")

    //SelectedItems.printSchema()
    //SelectedItems.show(5,true)

    //SelectedItems.repartition(1)
    //SelectedItems.repartition(functions.col("POS"))
    // Write out to file. TODO write out to S3
    //SelectedItems.write.format("com.databricks.spark.csv").option("header", "false").mode("overwrite").save("/tmp/scrape/")


  }
}
