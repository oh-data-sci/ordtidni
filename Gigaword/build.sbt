name := "OrdtidniXML"

version := "0.1"

scalaVersion := "2.12.15"

compileOrder := CompileOrder.JavaThenScala

dependencyOverrides += "com.fasterxml.jackson.core" % "jackson-databind" % "2.6.7"

libraryDependencies += "org.apache.hadoop" % "hadoop-aws" % "3.2.1"
libraryDependencies += "org.apache.hadoop" % "hadoop-common" % "3.2.1"
libraryDependencies += "org.apache.hadoop" % "hadoop-client" % "3.2.1"
libraryDependencies += "org.apache.spark" % "spark-core_2.12" % "3.2.1"
libraryDependencies += "org.apache.spark" % "spark-sql_2.12" % "3.2.1" 
libraryDependencies += "com.databricks" % "spark-xml_2.12" % "0.14.0"

libraryDependencies += "com.amazonaws" % "aws-java-sdk-s3" % "1.11.271"




//scalacOptions ++= Seq("-no-specialization")
