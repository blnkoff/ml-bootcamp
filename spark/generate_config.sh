#!/bin/bash
"""
Shell script to generate spark-defaults.conf from environment variables.
This script reads S3_ENDPOINT, S3_ACCESS_KEY, S3_SECRET_KEY and other S3-related
environment variables from .env file and generates spark-defaults.conf.
"""

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
OUTPUT_FILE="$SCRIPT_DIR/spark-defaults.conf"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Load environment variables from .env file
# Read .env file line by line and export valid KEY=VALUE pairs
while IFS= read -r line || [ -n "$line" ]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue
    
    # Export valid KEY=VALUE pairs
    if [[ "$line" =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
        key="${BASH_REMATCH[1]// /}"
        value="${BASH_REMATCH[2]}"
        # Remove quotes if present
        value="${value#\"}"
        value="${value%\"}"
        value="${value#\'}"
        value="${value%\'}"
        export "$key=$value"
    fi
done < "$ENV_FILE"

# Check if required environment variables are set
if [ -z "$S3_ENDPOINT" ]; then
    echo "Warning: S3_ENDPOINT not found in .env file, using empty value"
fi

if [ -z "$S3_ACCESS_KEY" ]; then
    echo "Warning: S3_ACCESS_KEY not found in .env file, using empty value"
fi

if [ -z "$S3_SECRET_KEY" ]; then
    echo "Warning: S3_SECRET_KEY not found in .env file, using empty value"
fi

# Generate spark-defaults.conf content
cat > "$OUTPUT_FILE" << EOF
# === S3/MinIO access ===
# This file is auto-generated from environment variables
# Do not edit manually - changes will be overwritten

spark.hadoop.fs.s3a.endpoint             ${S3_ENDPOINT:-}
spark.hadoop.fs.s3a.access.key           ${S3_ACCESS_KEY:-}
spark.hadoop.fs.s3a.secret.key           ${S3_SECRET_KEY:-}
spark.hadoop.fs.s3a.path.style.access    ${S3_PATH_STYLE_ACCESS:-true}
spark.hadoop.fs.s3a.connection.ssl.enabled ${S3_SSL_ENABLED:-false}
spark.hadoop.fs.s3a.impl                 org.apache.hadoop.fs.s3a.S3AFileSystem
EOF

echo "Successfully generated $OUTPUT_FILE"
echo "S3_ENDPOINT: ${S3_ENDPOINT:-<not set>}"
echo "S3_ACCESS_KEY: ${S3_ACCESS_KEY:-<not set>}"
echo "S3_SECRET_KEY: ${S3_SECRET_KEY:+<set>}"

