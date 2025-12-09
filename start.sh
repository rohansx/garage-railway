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

# Generate config file at runtime (bypasses any cached template)
cat > /etc/garage.toml << CONFIGEOF
# Garage configuration for Railway deployment
metadata_dir = "/var/lib/garage/meta"
data_dir = "/var/lib/garage/data"
db_engine = "lmdb"

replication_factor = 1

rpc_bind_addr = "[::]:3901"
rpc_public_addr = "127.0.0.1:3901"
rpc_secret = "$GARAGE_RPC_SECRET"

[s3_api]
s3_region = "garage"
api_bind_addr = "[::]:3900"
root_domain = ".s3.garage.localhost"

[s3_web]
bind_addr = "[::]:3902"
root_domain = ".web.garage.localhost"
index = "index.html"

[admin]
api_bind_addr = "[::]:3903"
admin_token = "$GARAGE_ADMIN_TOKEN"
metrics_token = "$GARAGE_METRICS_TOKEN"
CONFIGEOF

echo "Starting Garage..."
echo "S3 API: port 3900"
echo "Admin API: port 3903"

# Debug: show generated config
echo "=== Generated Config ==="
cat /etc/garage.toml
echo "=== End Config ==="

# Start garage
exec /garage server
