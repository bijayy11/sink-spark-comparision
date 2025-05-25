from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, from_unixtime, to_timestamp
from pyspark.sql.types import StructType, IntegerType, DoubleType, LongType
import pymysql

# Define the schema of the Kafka message value
schema = StructType() \
    .add("id", IntegerType()) \
    .add("latitude", DoubleType()) \
    .add("longitude", DoubleType()) \
    .add("temperature", DoubleType()) \
    .add("ts_produced", LongType())  # milliseconds

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("KafkaToMySQL") \
    .config("spark.jars", "file:///Users/b/streaming/spark-streaming/jars/mysql-connector-java-8.0.29.jar") \
    .getOrCreate()

spark.sparkContext.setLogLevel("WARN")

# Read from Kafka
df_kafka = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9094") \
    .option("subscribe", "spark-test-topic") \
    .option("startingOffsets", "latest") \
    .load()

# Parse Kafka JSON value and convert ts_produced (in ms) to proper timestamp
df_parsed = df_kafka.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), schema).alias("data")) \
    .select("data.*") \
    .withColumn("ts_produced", to_timestamp(from_unixtime(col("ts_produced") / 1000)))

# Function to perform upserts into MySQL
def upsert_to_mysql(batch_df, batch_id):
    batch_pd = batch_df.toPandas()
    if batch_pd.empty:
        return

    connection = pymysql.connect(
        host='localhost',
        user='root',
        password='password',
        database='testdb',
        autocommit=True
    )

    try:
        with connection.cursor() as cursor:
            for _, row in batch_pd.iterrows():
                cursor.execute("""
                    INSERT INTO sensor_data (id, latitude, longitude, temperature, ts_produced)
                    VALUES (%s, %s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE
                        latitude = VALUES(latitude),
                        longitude = VALUES(longitude),
                        temperature = VALUES(temperature),
                        ts_produced = VALUES(ts_produced)
                """, (
                    row['id'],
                    row['latitude'],
                    row['longitude'],
                    row['temperature'],
                    row['ts_produced'].strftime('%Y-%m-%d %H:%M:%S') if row['ts_produced'] else None
                ))
    finally:
        connection.close()

# Start streaming write with upsert functionality
query = df_parsed.writeStream \
    .foreachBatch(upsert_to_mysql) \
    .outputMode("update") \
    .start()

query.awaitTermination()
