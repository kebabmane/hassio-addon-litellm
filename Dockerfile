FROM python:3.11-alpine

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install system dependencies
RUN apk add --no-cache bash curl jq

# Install Python packages without cache to avoid conflicts
RUN pip install --no-cache-dir bashio litellm

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Create config directory for Home Assistant
RUN mkdir -p /data

# Set working directory
WORKDIR /data

# Expose port
EXPOSE 4000

# Run script
CMD ["/run.sh"]