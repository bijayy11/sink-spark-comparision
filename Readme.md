# Real-Time Streaming UPSERTs with Spark Structured Streaming and Kafka Connect

This project demonstrates real-time Change Data Capture (CDC) and UPSERT operations into MySQL using two approaches:
- **Apache Spark Structured Streaming**
- **Kafka Connect JDBC Sink**

## Prerequisites

- Apache Kafka
- MySQL
- Apache Spark
- Kafka Connect with JDBC and Debezium connectors
- Mysql connector and debezium connector .jar files.
---

## Spark Structured Streaming Setup

### Submit Spark Job

To run the Spark job that reads from Kafka and performs UPSERTs to MySQL:

```bash
spark-submit \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.3.0,mysql:mysql-connector-java:8.0.29 \
  spark_kafka_to_mysql.py


```

Then run following commands to run the producer script to emulate streaming data: 

```
cd kafka-setup
python producer.py
```


To run kafka sink to write to mysql :

simply run the following commands and the pipeline will write the streaming data into mysql:

``` 
python producer-connect.py
```

