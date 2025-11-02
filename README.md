# ML Bootcamp Infrastructure

A comprehensive machine learning infrastructure setup using Docker Compose. This project provides a complete MLOps stack with workflow orchestration, data processing, experiment tracking, and storage solutions.

## 🏗️ Architecture

This project includes the following services:

- **Apache Airflow** - Workflow orchestration and scheduling
- **JupyterLab** - Interactive development environment with Spark integration
- **Apache Spark** - Distributed data processing cluster (1 master + 2 workers)
- **ClearML** - MLOps platform for experiment tracking and model management
- **MinIO** - S3-compatible object storage for data and models

All services are connected via a shared Docker network (`ml-infra-network`) for seamless communication.

## 🔌 Service Ports

| Service | Port | Description |
|---------|------|-------------|
| **Airflow** |
| airflow-apiserver | 8085 | Airflow web UI |
| flower | 5555 | Celery monitoring UI |
| **JupyterLab** |
| jupyterlab | 8888 | JupyterLab web interface |
| jupyterlab | 4040 | Spark application UI |
| **Spark** |
| spark-master | 8080 | Spark master UI |
| spark-master | 7077 | Spark master connection port |
| spark-worker-1 | 8081 | Spark worker 1 UI |
| spark-worker-2 | 8082 | Spark worker 2 UI |
| **ClearML** |
| apiserver | 8052 | ClearML API server |
| webserver | 8051 | ClearML web UI |
| fileserver | 8050 | ClearML file server |
| **MinIO** |
| minio | 9000 | MinIO API |
| minio | 9001 | MinIO console |

*Note: Ports can be customized via environment variables in respective `.env` files.*

## 📋 Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- At least 8GB of available RAM
- 20GB+ of free disk space

## 🚀 Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/blnkoff/ml-bootcamp
cd ml-bootcamp
```

### 2. Environment Configuration

Create `.env` files in each service directory with the required environment variables:

#### Main `.env` file (optional)
You can create a root `.env` file, but most services use their own `.env` files in their respective directories.

#### Service-specific `.env` files

**Jupyter** (`jupyter/.env`):
```bash
JUPYTER_TOKEN=your-secure-token
JUPYTER_PORT=8888
SPARK_APP_PORT=4040
```

**MinIO** (`minio/.env`):
```bash
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_API_PORT=9000
MINIO_CONSOLE_PORT=9001
```

**ClearML** (`clearml/.env`):
```bash
CLEARML_APISERVER_PORT=8052
CLEARML_FILES_HOST=http://localhost:8001
# Add other ClearML-specific variables
```

**Airflow** (`airflow/.env`):
```bash
AIRFLOW_UID=50000
AIRFLOW_IMAGE_NAME=apache/airflow:3.1.0
_AIRFLOW_WWW_USER_USERNAME=airflow
_AIRFLOW_WWW_USER_PASSWORD=airflow
```

**Spark** (`spark/.env`):
```bash
SPARK_MASTER_UI_PORT=8080
SPARK_MASTER_PORT=7077
SPARK_WORKER1_UI_PORT=8081
SPARK_WORKER2_UI_PORT=8082
```

### 3. Start All Services

Start the entire stack:

```bash
docker-compose up -d
```

Or start individual services:

```bash
# Start only specific services
docker-compose up -d jupyter spark minio

# Start all services
docker-compose up -d
```

### 4. Initialize Airflow (First Time Setup)

After starting Airflow, initialize the database:

```bash
cd airflow
docker-compose up airflow-init
```

## 🔧 Services Overview

### Apache Airflow

Workflow orchestration platform for managing ML pipelines.

- **Web UI**: http://localhost:8085
- **Default credentials**: `airflow` / `airflow`
- **DAGs location**: `airflow/dags/`
- **Logs**: `airflow/logs/`

### JupyterLab

JupyterLab with Spark integration and ML libraries pre-installed.

- **Web UI**: http://localhost:8888 (or configured port)
- **Token**: Set via `JUPYTER_TOKEN` in `jupyter/.env`
- **Spark UI**: http://localhost:4040 (or configured port)
- **Pre-installed packages**:
  - `clearml` - Experiment tracking
  - `minio` - MinIO client
  - `matplotlib`, `seaborn` - Data visualization
  - `scikit-learn` - Machine learning
  - `catboost` - Gradient boosting

### Apache Spark

Distributed computing cluster for large-scale data processing.

- **Spark Master UI**: http://localhost:8080
- **Worker 1 UI**: http://localhost:8081
- **Worker 2 UI**: http://localhost:8082
- **Spark Master URL**: `spark://spark-master:7077`
- **Configuration**: 1 master + 2 workers (1 core, 1GB RAM each)

### ClearML

MLOps platform for experiment tracking, model versioning, and collaboration.

- **API Server**: http://localhost:8052
- **Web UI**: Check ClearML configuration for UI port
- **File Server**: http://localhost:8001
- **Services**: API server, MongoDB, Redis, Elasticsearch, File server

### MinIO

S3-compatible object storage for data and models.

- **API Port**: http://localhost:9000
- **Console**: http://localhost:9001
- **Default credentials**: `minioadmin` / `minioadmin` (change in `.env`)
- **Pre-configured buckets**:
  - `raw` - Raw data storage
  - `processed` - Processed datasets
  - `models` - Model artifacts

## 💻 Usage Examples

### Using Spark from Jupyter

```python
from pyspark.sql import SparkSession

# Create new Spark session connected to cluster
spark = (
    SparkSession
    .builder
    .appName("docker-spark-cluster")
    .master("spark://spark-master:7077")
    .config("spark.submit.deployMode", "client")
    .config("spark.driver.host", "jupyterlab")
    .getOrCreate()
)

# Your Spark code here
df = spark.read.csv("data.csv")
```

### Connecting to MinIO

```python
from minio import Minio

client = Minio(
    "minio:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)

# List buckets
buckets = client.list_buckets()
for bucket in buckets:
    print(bucket.name)
```

### Using ClearML

```python
from clearml import Task

task = Task.init(project_name="My Project", task_name="My Experiment")

# Log metrics
task.logger.report_scalar("accuracy", "train", 0.95, iteration=0)

# Your ML code here
```

## 📁 Project Structure

```
ml-bootcamp/
├── airflow/              # Apache Airflow configuration
│   ├── dags/            # Airflow DAG definitions
│   ├── config/          # Airflow configuration files
│   └── docker-compose.yaml
├── clearml/             # ClearML MLOps platform
│   ├── docker-compose.yml
│   └── apiserver.conf
├── jupyter/             # JupyterLab environment
│   ├── Dockerfile
│   ├── requirements.txt
│   └── docker-compose.yml
├── minio/               # MinIO object storage
│   ├── docker-compose.yml
│   └── bootstrap_buckets.sh
├── spark/               # Apache Spark cluster
│   ├── docker-compose.yml
│   └── build/workspace/
├── docker-compose.yml   # Main orchestration file
└── README.md
```

## 🔍 Monitoring and Management

### Check Service Status

```bash
docker-compose ps
```

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f jupyterlab
docker-compose logs -f spark-master
```

### Stop Services

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ deletes data)
docker-compose down -v
```

## 🛠️ Troubleshooting

### Port Conflicts

If you encounter port conflicts, modify the port mappings in the respective `docker-compose.yml` files or update your `.env` files.

### Airflow Database Issues

Reset Airflow database:
```bash
cd airflow
docker-compose down -v
docker-compose up airflow-init
```

### Spark Connection Issues

Ensure all Spark services are running:
```bash
docker-compose ps | grep spark
```

### ClearML Services Not Starting

Check dependencies are ready:
```bash
docker-compose logs clearml-apiserver
```

### MinIO Bucket Creation

Buckets are automatically created on startup. To manually create:
```bash
docker exec -it minio-init /bootstrap_buckets.sh
```

## 📝 Notes

- **Development Use**: This configuration is designed for local development. For production deployments, review security settings, resource limits, and backup strategies.
- **Resource Requirements**: Ensure your system has adequate resources for all services. Consider adjusting Spark worker resources based on your needs.
- **Data Persistence**: Data is stored in Docker volumes. Backup important data regularly.
- **Network**: All services communicate via the `ml-infra-network` Docker network.

## 🔐 Security Considerations

- **Change default passwords** for all services before deploying
- **Use environment variables** for sensitive credentials
- **Restrict network access** in production environments
- **Enable SSL/TLS** for production deployments
- **Regularly update** Docker images to latest versions

## 📚 Additional Resources

- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [ClearML Documentation](https://clear.ml/docs/)
- [MinIO Documentation](https://min.io/docs/)
- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is provided as-is for educational and development purposes.

---

**Happy ML Experimenting! 🚀**

