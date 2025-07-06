FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    bash \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip first
RUN python3 -m pip install --upgrade pip

# Install only litellm (skip bashio for now)
RUN pip3 install --no-cache-dir litellm

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