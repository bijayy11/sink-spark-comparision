# from kafka import KafkaProducer
# import json
# import time
# import random

# producer = KafkaProducer(
#     bootstrap_servers='localhost:9094',
#     key_serializer=lambda k: str(k).encode('utf-8'),  # <-- key serializer added
#     value_serializer=lambda v: json.dumps(v).encode('utf-8')
# )

# for i in range(10):
#     key = i  # Key is required
#     message = {
#         "id": i,
#         "latitude": round(random.uniform(-90.0, 90.0), 6),
#         "longitude": round(random.uniform(-180.0, 180.0), 6),
#         "temperature": round(random.uniform(-30.0, 50.0), 2)
#     }
#     producer.send('spark-test-topic', key=key, value=message)
#     print(f"Produced: {message} with key: {key}")
#     time.sleep(1)

# producer.flush()


from kafka import KafkaProducer
import json
import time
import random

producer = KafkaProducer(
    bootstrap_servers='localhost:9094',
    key_serializer=lambda k: str(k).encode('utf-8'),
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

with open("produced_events.txt", "w") as f:
    for i in range(10):
        key = i
        message = {
            "id": i,
            "latitude": round(random.uniform(-90.0, 90.0), 6),
            "longitude": round(random.uniform(-180.0, 180.0), 6),
            "temperature": round(random.uniform(-30.0, 50.0), 2)
        }
        send_time = int(time.time() * 1000)
        f.write(f"{i},{send_time}\n")  # id,send_time
        producer.send('spark-test-topic', key=key, value=message)
        print(f"Produced: {message} with key: {key} at {send_time}")
        time.sleep(1)

producer.flush()
