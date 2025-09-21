#!/bin/bash

# ==============================================================================
# Home Assistant Add-on: LiteLLM Proxy
# Runs LiteLLM Proxy with simple configuration
# ==============================================================================

# Set default values (can be overridden by environment variables)
port=${PORT:-4000}
config_file=${CONFIG_FILE:-"config.yaml"}
log_level=${LOG_LEVEL:-"INFO"}
master_key=${MASTER_KEY:-""}

echo "Starting LiteLLM Proxy..."
echo "Port: ${port}"
echo "Config file: ${config_file}"
echo "Log level: ${log_level}"

# Ensure Prisma client is generated into the add-on config dir so it persists between restarts
schema_path=$(python3 - <<'PY'
import pathlib
import litellm
schema = pathlib.Path(litellm.__file__).parent / "proxy" / "prisma" / "schema.prisma"
print(schema)
PY
)

prisma_cache_dir="/config/addons_config/litellm/prisma"
mkdir -p "${prisma_cache_dir}"

if [[ -f "${schema_path}" ]]; then
    echo "Copying Prisma schema to ${prisma_cache_dir}"
    cp "${schema_path}" "${prisma_cache_dir}/schema.prisma"
    echo "Generating Prisma client using schema at ${prisma_cache_dir}/schema.prisma"
    pushd "${prisma_cache_dir}" >/dev/null || {
        echo "Failed to enter ${prisma_cache_dir}; cannot continue." >&2
        exit 1
    }
    if ! python3 -m prisma generate --schema "${prisma_cache_dir}/schema.prisma"; then
        popd >/dev/null
        echo "Failed to generate Prisma client; cannot continue." >&2
        exit 1
    fi
    popd >/dev/null
    if [[ ! -d "${prisma_cache_dir}/prisma" ]]; then
        echo "Prisma generation did not produce a client in ${prisma_cache_dir}/prisma" >&2
        exit 1
    fi
    export PYTHONPATH="${prisma_cache_dir}:${PYTHONPATH}"
    echo "PYTHONPATH updated to include generated Prisma client: ${PYTHONPATH}"
else
    echo "Prisma schema not found at ${schema_path}; skipping client generation."
fi

# Check if config file exists in the correct addon config directory
config_path="/config/addons_config/litellm/${config_file}"
if [[ -f "${config_path}" ]]; then
    echo "Using config file from /config/addons_config/litellm/${config_file}"
else
    echo "Config file not found in /config/addons_config/litellm/!"
    echo "Creating addon config directory and default config file..."
    
    # Create the addon config directory if it doesn't exist
    mkdir -p "/config/addons_config/litellm"
    
    # Create a basic default config if none exists
    cat > "${config_path}" << EOF
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
    
    echo "Default config created. Please customize /config/addons_config/litellm/${config_file} with your models and API keys."
fi

# Set environment variables for logging
export LITELLM_LOG_LEVEL="${log_level}"

# Prepare LiteLLM command arguments
LITELLM_ARGS=(
    "--config" "${config_path}"
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

echo "Starting LiteLLM with arguments: ${LITELLM_ARGS[*]}"

# Start LiteLLM using the direct CLI command
exec litellm "${LITELLM_ARGS[@]}"
