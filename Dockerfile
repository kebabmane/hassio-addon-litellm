# Use LiteLLM official image as base
FROM ghcr.io/berriai/litellm:main-latest

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install bashio for Home Assistant integration
RUN pip3 install --no-cache-dir bashio

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