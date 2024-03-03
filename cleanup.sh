#!/bin/bash
set -e

# Step 1: Tear down all containers managed by docker compose
echo -e "\nStep 1: Tearing down all containers managed by docker compose..."
sudo docker compose down --volumes --remove-orphans || { echo "Error: Step 1 failed"; exit 1; }

# Step 2: Removing TIG-Stack images
echo -e "\nStep 2: Removing TIG-Stack images..."
sudo docker image rm grafana/grafana:10.3.1 influxdb:2.7.1 telegraf:latest || { echo "Error: Step 2 failed"; exit 1; }

# Step 3: Remove TIG-Stack volume
echo -e "\nStep 3: Removing TIG-Stack volume..."
sudo docker volume rm grafana-volume || { echo "Error: Step 3 failed"; exit 1; }

# Step 4: Change directory
cd ..

# Step 5: Remove directory
echo -e "\nStep 4: Removing directory 9800_telemetry_collector..."
sudo rm -rf 9800_telemetry_collector || { echo "Error: Step 4 failed"; exit 1; }

echo -e "\nCleanup completed."
