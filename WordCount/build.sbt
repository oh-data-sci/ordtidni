name := "OrdtidniXML"

version := "0.1"

//scalaVersion := "2.13.0"
//scalaVersion := "2.12.8"
scalaVersion := "2.11.12"
//scalaVersion := "2.10.0"
compileOrder := CompileOrder.JavaThenScala
// https://mvnrepository.com/artifact/org.apache.spark/spark-core

//libraryDependencies += "com.fasterxml.jackson.core" % "jackson-databind" % "2.6.7.1"
//libraryDependencies += "com.fasterxml.jackson.core" % "jackson-databind" % "2.7.8"

dependencyOverrides += "com.fasterxml.jackson.core" % "jackson-databind" % "2.6.7"


//libraryDependencies += "org.apache.hadoop" % "hadoop-aws" % "2.6.5"
//libraryDependencies += "org.apache.hadoop" % "hadoop-common" % "2.6.5"
libraryDependencies += "org.apache.hadoop" % "hadoop-aws" % "3.1.2"
libraryDependencies += "org.apache.hadoop" % "hadoop-common" % "3.1.2"
libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "2.6.5"
libraryDependencies += "org.apache.spark" % "spark-core_2.11" % "2.4.3"
libraryDependencies += "org.apache.spark" % "spark-sql_2.11" % "2.4.3" 
libraryDependencies += "com.databricks" % "spark-xml_2.11" % "0.5.0"
//libraryDependencies += "com.amazonaws" % "aws-java-sdk" %   "2.7.9"
libraryDependencies += "com.amazonaws" % "aws-java-sdk-s3" % "1.11.271"
//libraryDependencies += "com.amazonaws" % "aws-java-sdk" %   "1.7.4"



//scalacOptions ++= Seq("-no-specialization")
