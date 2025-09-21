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
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip first
RUN python3 -m pip install --upgrade pip

# Install litellm with proxy extras, prisma client, and bundled tzdata fallback
RUN pip3 install --no-cache-dir "litellm[proxy]" prisma tzdata

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Create directories for Home Assistant
RUN mkdir -p /config

# Set working directory
WORKDIR /config

# Expose port
EXPOSE 4000

# Run script
CMD ["/run.sh"]
