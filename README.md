# Garage Railway Template

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/YOUR_TEMPLATE_ID)

One-click deployment of [Garage](https://garagehq.deuxfleurs.fr/) - A lightweight, self-hosted S3-compatible distributed object storage system.

## Features

- S3-compatible API
- Lightweight (runs on minimal resources)
- Built-in web interface for static site hosting
- Admin API for management
- No external dependencies (no ZooKeeper/etcd required)
- Written in Rust for performance

## Quick Start

1. Click the "Deploy on Railway" button above
2. Wait for deployment to complete
3. Access the Admin API to configure buckets and keys

## Ports

| Port | Service | Description |
|------|---------|-------------|
| 3900 | S3 API | Main S3-compatible endpoint |
| 3901 | RPC | Node-to-node communication |
| 3902 | Web | Static website hosting |
| 3903 | Admin | Administration API |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GARAGE_RPC_SECRET` | Auto-generated | 64-char hex string for RPC auth |
| `GARAGE_ADMIN_TOKEN` | Auto-generated | Token for Admin API access |
| `GARAGE_METRICS_TOKEN` | Auto-generated | Token for metrics endpoint |

## Initial Setup

After deployment, you need to configure the cluster layout:

```bash
# Check node status
curl -H "Authorization: Bearer $GARAGE_ADMIN_TOKEN" http://your-url:3903/v1/status

# The node ID will be shown in logs on first start
# Apply layout (replace NODE_ID with actual value)
garage layout assign -z dc1 -c 1G <NODE_ID>
garage layout apply --version 1
```

## Creating Buckets & Keys

```bash
# Create a bucket
garage bucket create my-bucket

# Create an access key
garage key create my-key

# Allow key to access bucket
garage bucket allow --read --write my-bucket --key my-key
```

## Using with AWS CLI

```bash
aws configure set aws_access_key_id <ACCESS_KEY_ID>
aws configure set aws_secret_access_key <SECRET_KEY>

aws --endpoint-url http://your-url:3900 s3 ls
aws --endpoint-url http://your-url:3900 s3 cp file.txt s3://my-bucket/
```

## Links

- [Garage Documentation](https://garagehq.deuxfleurs.fr/documentation/)
- [Garage GitHub](https://git.deuxfleurs.fr/Deuxfleurs/garage)
- [Docker Hub](https://hub.docker.com/r/dxflrs/garage)
