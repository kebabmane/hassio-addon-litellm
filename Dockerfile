FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    git \
    jq \
    python3 \
    python3-pip \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip first
RUN python3 -m pip install --upgrade pip

# Install litellm from the latest main branch along with extras
RUN pip3 install --no-cache-dir "litellm[proxy] @ git+https://github.com/BerriAI/litellm.git@main" prisma tzdata

# Set timezone data directory for Python
ENV PYTHONPATH="/usr/share/zoneinfo:$PYTHONPATH"

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
