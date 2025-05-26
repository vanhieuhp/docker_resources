# Docker Development Environment

A comprehensive collection of pre-configured Docker environments for development purposes. This repository contains ready-to-use Docker Compose configurations for popular services and tools, allowing developers to quickly set up their development environment.

## 📋 Available Services

### Database Systems
- MySQL
- PostgreSQL
- MongoDB
- ClickHouse
- Elasticsearch

### Message Brokers & Streaming
- RabbitMQ
- Apache Kafka
- Apache Flink

### Caching & Storage
- Redis
- Minio (S3-compatible storage)

### Monitoring & Observability
- Prometheus
- Grafana
- Zipkin
- Kibana
- Logstash Server

### API Gateway & Authentication
- Kong Gateway
- Keycloak

### Development Tools
- Jupyter Notebook
- SonarQube
- Ghost (Content Platform)
- FFmpeg
- Node.js Environment

### Data Integration
- Debezium
- Monstache (MongoDB-Elasticsearch sync)

## 🚀 Getting Started

### Prerequisites
- Docker Engine installed
- Docker Compose v2.0 or later
- Git (for cloning the repository)
- Minimum 8GB RAM recommended
- At least 20GB free disk space

### Quick Start
1. Clone the repository:
```bash
git clone <repository-url>
cd dockers
```

2. Choose the service you want to run. Each service is in its own directory with its Docker Compose file.

3. Start a service (example with MySQL):
```bash
cd mysql
docker compose up -d
```

## 📁 Project Structure
Each service is organized in its own directory with the following structure:
```
servicename/
├── docker-compose.yml    # Service configuration
├── config/              # Configuration files
├── data/                # Data persistence (gitignored)
└── README.md           # Service-specific documentation
```

## 🛠 Common Operations

### Clean Up Docker Resources
Remove dangling images:
```bash
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
```

### Data Persistence
- All service data is stored in their respective `data` directories
- Backup these directories if you need to preserve your data
- The `data` directories are included in `.gitignore`

## 🔧 Service-Specific Instructions

### Database Services

#### MySQL
- Default port: 3306
- Default credentials: See mysql/docker-compose.yml
- Data directory: mysql/data

#### PostgreSQL
- Default port: 5432
- Configuration directory: postgresql/config
- Data directory: postgresql/data

#### MongoDB
- Default port: 27017
- Data directory: mongodb/data

### Message Brokers

#### RabbitMQ
- Management UI: http://localhost:15672
- AMQP port: 5672
- Default credentials: guest/guest

#### Apache Kafka
- Broker port: 9092
- Zookeeper port: 2181
- Data directories:
  ```bash
  mkdir -p kafka/data/zookeeper kafka/data/kafka
  sudo chown -R 1000:1000 kafka/data/*
  ```

### Monitoring Stack

#### Prometheus + Grafana
- Prometheus UI: http://localhost:9090
- Grafana UI: http://localhost:3000
- Default Grafana credentials: admin/admin

#### Kibana + Elasticsearch
- Kibana UI: http://localhost:5601
- Elasticsearch API: http://localhost:9200

### Development Tools

#### Jupyter Notebook
- Access at: http://localhost:8888
- Token is displayed in container logs

#### SonarQube
- Web UI: http://localhost:9000
- Default credentials: admin/admin

## 🔐 Security Notes
- Default credentials are provided for development purposes only
- Change all default passwords in production environments
- Use `.env` files for sensitive configurations (template provided)
- Never commit sensitive data to the repository

## 🤝 Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting
- Check container logs: `docker logs container_name`
- Ensure ports are not already in use
- Verify sufficient system resources
- Check service-specific README files for detailed troubleshooting

## 📚 Additional Resources
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- Individual service documentation in their respective directories
