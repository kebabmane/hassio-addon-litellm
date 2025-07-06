ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Python and LiteLLM
RUN apk add --no-cache \
    python3 \
    py3-pip \
    bash \
    curl \
    jq \
    gcc \
    python3-dev \
    musl-dev \
    libffi-dev \
    openssl-dev

# Install bashio and LiteLLM
RUN pip3 install --no-cache-dir bashio litellm[proxy]

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