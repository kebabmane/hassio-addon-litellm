# LiteLLM Home Assistant Add-on Repository

This repository contains a Home Assistant add-on for [LiteLLM Proxy](https://github.com/BerriAI/litellm), a universal API gateway that allows you to call 100+ LLMs using the OpenAI format.

## Installation

### Step 1: Add Repository to Home Assistant

1. In Home Assistant, go to **Settings** → **Add-ons** → **Add-on Store**
2. Click the **⋮** (three dots) menu in the top right
3. Select **Repositories**
4. Add this repository URL: `https://github.com/kebabmane/hassio-addon-litellm`
5. Click **Add**

### Step 2: Install the Add-on

1. Refresh the Add-on Store page
2. Find "LiteLLM Proxy" in the list of available add-ons
3. Click on it and then click **Install**

### Step 3: Configure the Add-on

1. Go to the **Configuration** tab
2. Set your desired port (default: 4000)
3. Optionally set a master key for authentication
4. Click **Save**

### Step 4: Create Configuration File

1. Create a file called `config.yaml` in your `/addons_config/litellm/` directory (older installs may still use `/addon_configs/litellm_proxy/`)
2. Use the example configuration from the add-on documentation
3. Add your API keys, model configurations, and any optional database settings

### Step 5: Start the Add-on

1. Go to the **Info** tab
2. Click **Start**
3. Check the **Log** tab for any errors

## Configuration Example

Create `/addons_config/litellm/config.yaml` (older installs may still use `/addon_configs/litellm_proxy/config.yaml`):

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY

  - model_name: claude-3-sonnet
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: os.environ/ANTHROPIC_API_KEY

litellm_settings:
  drop_params: true
  set_verbose: false
  telemetry: false

general_settings:
  master_key: "your-secret-key"
  database_url: "postgresql://user:pass@host:5432/litellm"
  store_model_in_db: true
  timezone: "Australia/Sydney"
```

## Database Configuration

- **Purpose**: LiteLLM can persist request metadata, usage logs, rate limits, billing information, and store model configurations when you supply a database connection URL. Without it, all data is held in memory and lost on restart.

### Database Options

- **PostgreSQL (recommended for production)**: Required for full feature support including UI model management.

```yaml
general_settings:
  master_key: "your-secret-key"
  database_url: "postgresql://user:pass@host:5432/litellm"
  store_model_in_db: true
```

- **SQLite (basic use only)**: Suitable for logging and basic functionality, but PostgreSQL is recommended for model storage features.

```yaml
general_settings:
  master_key: "your-secret-key"
  database_url: "sqlite:////config/addons_config/litellm/litellm.db"
```

### Important Settings

- **store_model_in_db**: Set to `true` to enable adding/managing models via the LiteLLM UI. This feature works best with PostgreSQL.
- **Create the path**: For SQLite, Home Assistant mounts `/config` into the add-on, so the above path will live at `config/addons_config/litellm/litellm.db` on the host. LiteLLM will create the SQLite file automatically on first start.
- **Network access**: For PostgreSQL, ensure the host is reachable from the add-on container and network access is allowed.
- **Apply changes**: After updating the config file, restart the add-on so LiteLLM picks up the new database connection.
- **Timezone (optional)**: Set `general_settings.timezone` to propagate a specific `TZ` (for example `Australia/Sydney`) into the add-on container if you need to override Home Assistant's default.

## Environment Variables

Set your API keys in Home Assistant's `secrets.yaml`:

```yaml
openai_api_key: "sk-your-openai-key"
anthropic_api_key: "sk-ant-your-anthropic-key"
```

## Usage

Once running, the LiteLLM Proxy will be available at:
- API: `http://homeassistant.local:4000`
- Documentation: `http://homeassistant.local:4000/docs`

## Support

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [Home Assistant Community](https://community.home-assistant.io/)
- [Issues](https://github.com/kebabmane/hassio-addon-litellm/issues)

## Add-ons in this Repository

- **LiteLLM Proxy**: Universal LLM API Gateway
