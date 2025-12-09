# Garage S3-compatible object storage for Railway
FROM alpine:3.19

# Cache bust
ARG CACHEBUST=1

# Install dependencies
RUN apk add --no-cache curl ca-certificates

# Download Garage binary
RUN wget -O /garage https://garagehq.deuxfleurs.fr/_releases/v2.1.0/x86_64-unknown-linux-musl/garage && \
    chmod +x /garage

# Create directories
RUN mkdir -p /var/lib/garage/meta /var/lib/garage/data

# Copy startup script (config is generated at runtime)
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Garage ports:
# 3900 - S3 API endpoint
# 3901 - RPC communication
# 3902 - S3 web interface
# 3903 - Admin API

# Use Admin API port for Railway's healthcheck (has /health endpoint)
ENV PORT=3903

EXPOSE 3900 3901 3902 3903

# Health check on admin API
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:3903/health || exit 1

CMD ["/start.sh"]
