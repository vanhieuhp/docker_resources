#!/bin/bash

# Build Docker image
docker build -t rabbitmq:delay-queue .

# Run Docker Compose
docker compose up -d
