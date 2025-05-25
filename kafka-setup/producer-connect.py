from confluent_kafka.avro import AvroProducer, load
import random
import time

# Load schemas
value_schema = load("sensor.avsc")
key_schema = load("sensor_key.avsc")  # <-- correct key schema

producer_config = {
    'bootstrap.servers': 'localhost:9092',
    'schema.registry.url': 'http://localhost:8081'
}

producer = AvroProducer(producer_config,
                        default_key_schema=key_schema,
                        default_value_schema=value_schema)

for i in range(1000):
    key = {"id": i}
    value = {
        "id": i,
        "latitude": round(random.uniform(-90.0, 90.0), 6),
        "longitude": round(random.uniform(-180.0, 180.0), 6),
        "temperature": round(random.uniform(-30.0, 50.0), 2),
        "ts_produced": int(time.time() * 1000) 
    }
    print("Producing:", value)
    producer.produce(topic='test-topic', key=key, value=value)
    time.sleep(0.01)

producer.flush()
