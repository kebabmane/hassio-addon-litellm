ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    jq

# Install bashio
RUN pip3 install --no-cache-dir bashio

# Use pre-built LiteLLM image content
RUN pip3 install --no-cache-dir litellm

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Create config directory
RUN mkdir -p /data

# Set working directory
WORKDIR /data

# Expose port
EXPOSE 4000

# Run script
CMD ["/run.sh"]