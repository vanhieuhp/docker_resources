#!/bin/bash

# Variables
KAFKA_BIN_DIR="/opt/kafka/bin"
TOPIC_NAME="demo-topic"
PARTITIONS=2
REPLICATION_FACTOR=1

# Create Kafka topic
$KAFKA_BIN_DIR/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor $REPLICATION_FACTOR --partitions $PARTITIONS --topic $TOPIC_NAME

echo "Topic '$TOPIC_NAME' created successfully."