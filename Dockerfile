ARG BUILD_FROM=ghcr.io/berriAI/litellm:main-latest
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install additional packages needed for Home Assistant integration
RUN apk add --no-cache \
    bash \
    curl \
    jq

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Create config directory
RUN mkdir -p /data

# Set working directory
WORKDIR /data

# Labels for Home Assistant add-on
LABEL \
    io.hass.name="LiteLLM Proxy" \
    io.hass.description="Universal LLM API Gateway" \
    io.hass.arch="armhf|armv7|aarch64|amd64|i386" \
    io.hass.type="addon" \
    io.hass.version="1.0.0"

# Expose port
EXPOSE 4000

# Run script
CMD ["/run.sh"]