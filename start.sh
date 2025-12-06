#!/bin/sh
set -e

# Generate secrets if not provided
if [ -z "$GARAGE_RPC_SECRET" ]; then
    GARAGE_RPC_SECRET=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 64)
    echo "Generated RPC secret (save this for multi-node setups): $GARAGE_RPC_SECRET"
fi

if [ -z "$GARAGE_ADMIN_TOKEN" ]; then
    GARAGE_ADMIN_TOKEN=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 32)
    echo "Generated admin token: $GARAGE_ADMIN_TOKEN"
fi

if [ -z "$GARAGE_METRICS_TOKEN" ]; then
    GARAGE_METRICS_TOKEN=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 32)
    echo "Generated metrics token: $GARAGE_METRICS_TOKEN"
fi

# Create config from template
cp /etc/garage/garage.toml.template /etc/garage.toml

# Replace placeholders with actual values
sed -i "s/RPC_SECRET_PLACEHOLDER/$GARAGE_RPC_SECRET/g" /etc/garage.toml
sed -i "s/ADMIN_TOKEN_PLACEHOLDER/$GARAGE_ADMIN_TOKEN/g" /etc/garage.toml
sed -i "s/METRICS_TOKEN_PLACEHOLDER/$GARAGE_METRICS_TOKEN/g" /etc/garage.toml

echo "Starting Garage..."
echo "S3 API: port 3900"
echo "Admin API: port 3903"

# Start garage
exec /garage server
