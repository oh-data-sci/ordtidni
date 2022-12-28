//import org.apache.spark.sql.{SparkSession, functions}
import org.apache.spark.sql._
import org.apache.spark.sql.functions
import org.apache.spark.sql.expressions.Window
import com.databricks.spark.xml._




object XMLScraper {
  def main(args: Array[String]) {

    val n = args.length

    val l_usage = "Usage: XMLScraper  --source Source [--year Year] " +
      "[--month Month] \n" +
      "e.g.  mbl 2015 10 \n" +
      " or althingi \n"

    if(n < 2)
      throw new Exception ("Must provide source  "+ l_usage)

    val arglist = args.toList


    type OptionMap = Map[Symbol, Any]
    def nextOption(map : OptionMap, list: List[String]) : OptionMap = {
      def isSwitch(s : String) = (s(0) == '-')
      list match {
        case Nil => map
//        case "--dataset" :: value :: tail =>
//          nextOption(map ++ Map('dataset -> value.toString), tail)
        case "--source" :: value :: tail =>
          nextOption(map ++ Map('source -> value.toString), tail)
        case "--year" :: value :: tail =>
          nextOption(map ++ Map('year -> value.toString), tail)
        case "--month" :: value :: tail =>
          nextOption(map ++ Map('month -> value.toString), tail)
        case "--sourceFS" :: value :: tail =>
          nextOption(map ++ Map('sourceFS -> value.toString), tail)
        case "--targetFS" :: value :: tail =>
          nextOption(map ++ Map('targetFS -> value.toString), tail)
        case option :: tail => println("Unknown option "+option)
          throw new Exception ("Unknown options: "+ arglist.toStream)
      }
    }

    val l_options = nextOption(Map(),arglist)
    println(l_options)
   // var l_ds = l_options('dataset)
    //println(l_ds)
    val l_source = l_options.getOrElse('source,"No Source")
    println("Source: " + l_source)
    var l_year = l_options.getOrElse('year,"*")
    println("Year:" + l_year)
    var l_month = l_options.getOrElse('month,"*")
    println("Month: " + l_month)
    val l_sourceFS = l_options.getOrElse('sourceFS,"s3a://ordtidni/XML")
    println(l_sourceFS)
    val l_targetFS = l_options.getOrElse('targetFS,"s3a://ordtidni/output")
    println(l_targetFS)

    if(l_source == "No Source")
      throw new Exception ("No Source provided  "  + arglist.toStream)

    //Deal with my lame wildcard values
    if(l_year == "*") {
      //l_year = "*"
      l_month = "*"
    }


    //Input string needs wildcards
    val l_inputString  = l_sourceFS+"/" + l_source + "/" +l_year //+ "/" +l_month

    //Output strings needs blanks, to collapse the data to the highest level
    // e.g. if no month is given, data will end up on the year level
    // e.g. if no year is given, data will end up on the source level

    if(l_year == "*")
      l_year=""

    if(l_month == "*")
      l_month=""

    val l_outputString = l_targetFS +"/" +  l_source + "/" +l_year+  "/"  +l_month


    println("Input:  "+l_inputString)
    println("Output: "+l_outputString)

    //throw new Exception (l_usage+" " + arglist.toStream)

    // TODO This is perhaps better done with Spark Streaming ?
    // TODO handle dataset, source, year and month. Still think Spark Streaming is what we need
    // Let's get the Spark context
    //If running in IntelliJ we must set the master, and appname
    //val sc = SparkSession.builder.master("local").appName("XMLScraper").getOrCreate()
    // Else get it from spark-submit call
    val sc = SparkSession.builder.getOrCreate()

    //Create a schema object
    //Get the schema from a single XML example to use for the bulk, /tmp/schema.xml is a copy of any random datafile.
    // TODO: Handle this better, e.g. read the first file from the input string?
    // TODO: Can the schema be saved as a file in the project?
    val giga_schema = sc.read
      .format("com.databricks.spark.xml")
      .option("rootTag","body")
      .option("rowTag", "p") // Only reading in 'P' = 'Paragraph'
      .xml("/tmp/schema.xml")
      .schema

    giga_schema.printTreeString()
    //Read all the files in the input string
    //Construct a single data frame containing the Lemma,Type and actual word.
    //_n is <p n="1"> i.e. paragraph number
    //s._n is <s n="1"> i.e. sentence number within the paragraph

    val windowSpec = Window.partitionBy(/*"input_file", "Paragraph" ,*/"Sentence").orderBy("WordID")
    // TODO 
    val df = sc.read
      .format("com.databricks.spark.xml")
      .option("rootTag","body")
      .option("rowTag", "p") // Only reading in 'P' = 'Paragraphs'
      .schema(giga_schema) //This saved 10 minutes over 43.000 files. fro 10m to 0.4 s for this step. (morgunbladid/2015). Using one XML file as the schema to avoid schema discovery each time
      .xml(l_inputString+"/*.xml") // Given dataset, source and year: add all months and all XML files

    //df.show()
    // WTF does this ol' regexp do?
    val regexp = "[\\/]([^\\/]+[\\/][^\\/]+)$"

      val selected =
      df
        //.withColumn("input_file",functions.regexp_extract(functions.input_file_name(), regexp, 1))  // Capture the input filename
        .withColumn("Sents",functions.explode(functions.col("s"))) // Flatten out
        .withColumn("Words",functions.explode(functions.col("Sents.w")))
        //.withColumn("Paragraph",functions.col("_xml:id"))
        .withColumn("Sentence",functions.col("Sents._xml:id"))
        .withColumn("WordID",functions.col("Words._xml:id"))
        .withColumn("word_number", functions.row_number().over(windowSpec)) // Add the word number within the sentence
        .select( "Sentence","word_number","Words._lemma" ,"Words._pos","Words._VALUE")
        //.select("input_file","Paragraph" ,"Sentence","word_number","Words._lemma" ,"Words._type","Words._VALUE")
        .toDF("Sentence","word_number","Lemma","POS","Word") // Just the columns we want.
        //.toDF("input_file","word_number","Lemma","POS","Word") // Just the columns we want.

    

    // TODO parameterise the number of partitions?
    //TODO parameterise output format
    selected
      .coalesce(1)
      .write
      .format("parquet")
      .option("spark.sql.parquet.mergeSchema","true")
      .mode("overwrite")
      .save(l_outputString) // save to output file system

    selected.printSchema()

  }
}
