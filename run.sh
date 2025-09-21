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

# Resolve config path early so we can reuse it
config_path="/config/addons_config/litellm/${config_file}"

echo "Starting LiteLLM Proxy..."
echo "Port: ${port}"
echo "Config file: ${config_file}"
echo "Log level: ${log_level}"

# Ensure Prisma client for litellm is available before starting the proxy
schema_path=$(python3 - <<'PY'
import pathlib
import litellm

base = pathlib.Path(litellm.__file__).parent
candidates = [
    base / "proxy" / "schema.prisma",
    base / "proxy" / "prisma" / "schema.prisma",
]

for candidate in candidates:
    if candidate.exists():
        print(candidate)
        break
else:
    print("")
PY
)

ensure_prisma_client() {
    python3 - <<'PY'
import sys

try:
    from prisma import Prisma  # noqa: F401
except Exception:
    sys.exit(1)
sys.exit(0)
PY
}

if [[ -f "${config_path}" ]]; then
    while IFS='=' read -r key value; do
        case "${key}" in
            DATABASE_URL)
                if [[ -z "${DATABASE_URL}" && -n "${value}" ]]; then
                    export DATABASE_URL="${value}"
                    echo "DATABASE_URL loaded from config file ${config_path}."
                fi
                ;;
            TZ)
                if [[ -n "${value}" ]]; then
                    export TZ="${value}"
                    export TZDIR="/usr/share/zoneinfo"
                    echo "TZ set from config file ${config_path}: ${TZ}"
                    echo "TZDIR set to: ${TZDIR}"
                fi
                ;;
        esac
    done < <(python3 - "${config_path}" <<'PY'
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    sys.exit()

config_path = Path(sys.argv[1])
if not config_path.exists():
    sys.exit()

with config_path.open("r", encoding="utf-8") as f:
    data = yaml.safe_load(f) or {}

general = data.get("general_settings") or {}

db_url = general.get("database_url")
if db_url:
    print(f"DATABASE_URL={db_url}")

timezone = general.get("timezone")
if timezone:
    print(f"TZ={timezone}")
PY
    )
fi

if [[ -z "${schema_path}" ]]; then
    echo "Prisma schema not found in litellm package; skipping client generation."
elif ensure_prisma_client; then
    echo "Prisma client already present; skipping generation."
else
    echo "Prisma client missing; attempting generation."
    prisma_pkg_dir=$(python3 - <<'PY'
import prisma, pathlib
print(pathlib.Path(prisma.__file__).parent)
PY
)
    echo "Detected prisma package directory: ${prisma_pkg_dir}"
    export PRISMA_HOME_DIR="/config/addons_config/litellm/.prisma_cache"
    export PRISMA_BINARY_CACHE_DIR="${PRISMA_HOME_DIR}/binaries"
    mkdir -p "${PRISMA_HOME_DIR}" "${PRISMA_BINARY_CACHE_DIR}"
    prisma_workdir="/config/addons_config/litellm/prisma_workdir"
    mkdir -p "${prisma_workdir}"
    work_schema="${prisma_workdir}/schema.prisma"
    cp "${schema_path}" "${work_schema}"
    python3 - "${work_schema}" "${prisma_pkg_dir}" <<'PY'
import pathlib
import sys

schema_path = pathlib.Path(sys.argv[1])
output_path = sys.argv[2]

text = schema_path.read_text()

lines = text.splitlines()
start = None
brace_depth = 0
for idx, line in enumerate(lines):
    stripped = line.strip()
    if start is None and stripped.startswith("generator") and "client" in stripped and "{" in stripped:
        start = idx
        brace_depth = line.count("{") - line.count("}")
        continue
    if start is not None:
        brace_depth += line.count("{") - line.count("}")
        if brace_depth == 0:
            block_lines = lines[start:idx + 1]
            if not any(l.strip().startswith("output") for l in block_lines):
                block_lines.insert(len(block_lines) - 1, f"  output   = \"{output_path}\"")
            lines[start:idx + 1] = block_lines
            break

schema_path.write_text("\n".join(lines) + "\n")
PY
    if [[ -z "${DATABASE_URL}" ]]; then
        export DATABASE_URL="postgresql://user:password@localhost:5432/postgres"
        echo "DATABASE_URL not set; using placeholder for generation."
    fi
    echo "Running prisma generate using schema ${work_schema}"
    if ! python3 -m prisma generate --schema "${work_schema}"; then
        echo "Prisma generate failed; cannot continue." >&2
        exit 1
    fi
    if ensure_prisma_client; then
        echo "Prisma client generated successfully at ${prisma_pkg_dir}."
    else
        echo "Prisma client generation completed but client still unavailable." >&2
        exit 1
    fi
fi

# Check if config file exists in the correct addon config directory
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
