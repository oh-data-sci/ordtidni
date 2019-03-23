import pathlib
import os

import findspark
import pyspark
from pyspark.sql import SparkSession
import pyspark.sql.functions as sfunc
import pyspark.sql.types as stypes


findspark.init()

os.environ['PYSPARK_SUBMIT_ARGS'] = "--packages org.apache.hadoop:hadoop-common:2.8.5,org.apache.hadoop:hadoop-aws:2.8.5,com.amazonaws:aws-java-sdk:1.11.271 pyspark-shell"


def spark_session(name='ds-spark-utils', executor_mem='4G', master='local[*]', driver_host='127.0.0.1', driver_memory='2G'):
    '''
    Create a spark session with defaults that work most of the time, including on a laptop.
    On AWS push up the executor_mem so that the memory is used efficiently.
    '''
    return SparkSession \
        .builder \
        .master(master) \
        .appName(name) \
        .config('spark.driver.host', driver_host) \
        .config('spark.executor.memory', executor_mem) \
        .config('spark.driver.memory', driver_memory) \
        .config('spark.driver.maxResultSize', '3G') \
        .config("spark.dynamicAllocation.enabled", "false") \
        .config("spark.hadoop.mapreduce.fileoutputcommitter.algorithm.version", "2") \
        .getOrCreate()
        #.config('spark.pyspark.python', '/usr/bin/python3') \


def read_or_create_s3_parquet(name, create_fn, parquet_bucket, spark=spark_session()):
    parquet_path = f'{parquet_bucket}/{name}'
    print(f'attempting read of {parquet_path}')
    try:
        df = spark.read.parquet(str(parquet_path))
    except:
        print('creating df...')
        df = create_fn()
        for col in df.columns:
            df = df.withColumnRenamed(col,col.strip().replace(" ", "_"))
        print(f'writing parquet {parquet_path}...')
        df.write.parquet(parquet_path)
        df = spark.read.parquet(str(parquet_path))
    return df


def check_nulls(df):
    ''' 
    Check data import and cleandliness. 
    Some classifiers break if fed null values
    '''
    df.select([sfunc.count(sfunc.when(sfunc.col(c).isNull(), c)).alias(c) for c in df.columns]).show()

