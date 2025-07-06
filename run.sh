#!/usr/bin/with-contenv bashio

# ==============================================================================
# Home Assistant Add-on: LiteLLM Proxy
# Runs LiteLLM Proxy with Home Assistant configuration
# ==============================================================================

# Install bashio if not available
if ! command -v bashio &> /dev/null; then
    echo "Installing bashio..."
    pip3 install bashio
fi

# Set default values
declare port
declare config_file
declare log_level
declare master_key

# Read configuration from Home Assistant
port=$(bashio::config 'port')
config_file=$(bashio::config 'config_file')
log_level=$(bashio::config 'log_level')
master_key=$(bashio::config 'master_key')

bashio::log.info "Starting LiteLLM Proxy..."
bashio::log.info "Port: ${port}"
bashio::log.info "Config file: ${config_file}"
bashio::log.info "Log level: ${log_level}"

# Check if config file exists
if [[ ! -f "/data/${config_file}" ]]; then
    bashio::log.warning "Config file /data/${config_file} not found!"
    bashio::log.info "Creating default config file..."
    
    # Create a basic default config if none exists
    cat > "/data/${config_file}" << EOF
model_list:
  - model_name: gpt-3.5-turbo
    litellm_params:
      model: gpt-3.5-turbo
      api_key: os.environ/OPENAI_API_KEY

litellm_settings:
  drop_params: true
  set_verbose: false
  telemetry: false

general_settings:
  master_key: "${master_key}"
EOF
    
    bashio::log.info "Default config created. Please customize /data/${config_file} with your models and API keys."
fi

# Set environment variables for logging
export LITELLM_LOG_LEVEL="${log_level}"

# Prepare LiteLLM command arguments
LITELLM_ARGS=(
    "--config" "/data/${config_file}"
    "--port" "${port}"
    "--host" "0.0.0.0"
)

# Add master key if provided
if [[ -n "${master_key}" ]]; then
    LITELLM_ARGS+=("--master_key" "${master_key}")
fi

# Add detailed debug if log level is DEBUG
if [[ "${log_level}" == "DEBUG" ]]; then
    LITELLM_ARGS+=("--detailed_debug")
fi

bashio::log.info "Starting LiteLLM with arguments: ${LITELLM_ARGS[*]}"

# Start LiteLLM
exec python3 -m litellm "${LITELLM_ARGS[@]}"