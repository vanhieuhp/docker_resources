#!/bin/bash
# Variables
KAFKA_BIN_DIR="/opt/kafka/bin"
TOPIC_NAME="demo-topic"

# Delete Kafka topic
$KAFKA_BIN_DIR/kafka-topics.sh --delete --bootstrap-server localhost:9092 --topic $TOPIC_NAME