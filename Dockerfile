# Build stage to prepare config
FROM alpine:3.19 AS builder

RUN apk add --no-cache openssl

WORKDIR /build

# Copy and prepare configuration
COPY garage.toml /build/garage.toml.template
COPY start.sh /build/start.sh

RUN chmod +x /build/start.sh

# Generate default secrets for template (users should override these)
RUN echo "Generating default secrets..." && \
    RPC_SECRET=$(openssl rand -hex 32) && \
    ADMIN_TOKEN=$(openssl rand -base64 32 | tr -d '\n') && \
    METRICS_TOKEN=$(openssl rand -base64 32 | tr -d '\n') && \
    sed -i "s/RPC_SECRET_PLACEHOLDER/$RPC_SECRET/g" /build/garage.toml.template && \
    sed -i "s/ADMIN_TOKEN_PLACEHOLDER/$ADMIN_TOKEN/g" /build/garage.toml.template && \
    sed -i "s/METRICS_TOKEN_PLACEHOLDER/$METRICS_TOKEN/g" /build/garage.toml.template && \
    cp /build/garage.toml.template /build/garage.toml && \
    echo "RPC_SECRET=$RPC_SECRET" > /build/secrets.env && \
    echo "ADMIN_TOKEN=$ADMIN_TOKEN" >> /build/secrets.env && \
    echo "METRICS_TOKEN=$METRICS_TOKEN" >> /build/secrets.env

# Final stage - use Alpine with Garage binary
FROM alpine:3.19

# Install curl for healthcheck
RUN apk add --no-cache curl ca-certificates

# Download and install Garage binary
RUN wget -O /garage https://garagehq.deuxfleurs.fr/_releases/v2.1.0/x86_64-unknown-linux-musl/garage && \
    chmod +x /garage

# Create directories
RUN mkdir -p /var/lib/garage/meta /var/lib/garage/data /etc/garage

# Copy config from builder
COPY --from=builder /build/garage.toml /etc/garage.toml
COPY --from=builder /build/secrets.env /etc/garage/secrets.env

# Garage ports:
# 3900 - S3 API endpoint
# 3901 - RPC communication (node-to-node)
# 3902 - S3 web interface
# 3903 - Admin API

ENV PORT=3900

EXPOSE 3900 3901 3902 3903

# Health check on admin API
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3903/health || exit 1

CMD ["/garage", "server"]
