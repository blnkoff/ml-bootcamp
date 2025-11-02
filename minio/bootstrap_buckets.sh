#!/bin/bash

until mc alias set myminio http://minio:9000 ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD}; do
  echo "Waiting for MinIO to be ready..."
  sleep 2
done

mc mb myminio/raw --ignore-existing      
mc mb myminio/processed --ignore-existing 
mc mb myminio/models --ignore-existing  

echo "MinIO buckets created successfully!"