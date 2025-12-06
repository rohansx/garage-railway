FROM dxflrs/garage:v2.1.0

# Garage ports:
# 3900 - S3 API endpoint
# 3901 - RPC communication (node-to-node)
# 3902 - S3 web interface
# 3903 - Admin API

# Create directories
RUN mkdir -p /var/lib/garage/meta /var/lib/garage/data /etc/garage

# Copy configuration template and start script
COPY garage.toml /etc/garage/garage.toml.template
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Environment defaults
ENV PORT=3900
ENV GARAGE_RPC_SECRET=""
ENV GARAGE_ADMIN_TOKEN=""
ENV GARAGE_METRICS_TOKEN=""

# Expose ports
EXPOSE 3900 3901 3902 3903

# Health check on S3 API
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3903/health || exit 1

CMD ["/start.sh"]
