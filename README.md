# Home Assistant Add-on: LiteLLM Proxy

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield] ![Supports armhf Architecture][armhf-shield] ![Supports armv7 Architecture][armv7-shield] ![Supports i386 Architecture][i386-shield]

LiteLLM Proxy is a universal API gateway that allows you to call 100+ LLMs using the OpenAI format. This Home Assistant add-on makes it easy to run LiteLLM Proxy locally within your Home Assistant environment.

## About

LiteLLM Proxy provides:
- **Universal API**: Call 100+ LLMs (OpenAI, Anthropic, Azure, Ollama, etc.) using OpenAI format
- **Load Balancing**: Distribute requests across multiple models/providers
- **Cost Tracking**: Monitor usage and costs across different providers
- **Caching**: Redis-based response caching
- **Authentication**: API key management and user authentication
- **Observability**: Logging, metrics, and integration with monitoring tools

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "LiteLLM Proxy" add-on
3. Configure the add-on (see Configuration section)
4. Start the add-on

## Configuration

### Add-on Configuration

```yaml
port: 4000
config_file: "config.yaml"
log_level: "INFO"
master_key: "your-secret-key"
```

- **port**: Port for the LiteLLM Proxy API (default: 4000)
- **config_file**: Name of the configuration file in `/addon_configs/` (default: config.yaml)
- **log_level**: Logging level (DEBUG, INFO, WARNING, ERROR)
- **master_key**: Master API key for authentication (optional but recommended)

### LiteLLM Configuration

Create a `config.yaml` file in your `/addon_configs/litellm_proxy/` directory. Here's an example:

```yaml
model_list:
  # OpenAI Models
  - model_name: gpt-4
    litellm_params:
      model: gpt-4
      api_key: os.environ/OPENAI_API_KEY
  
  - model_name: gpt-3.5-turbo
    litellm_params:
      model: gpt-3.5-turbo
      api_key: os.environ/OPENAI_API_KEY

  # Anthropic Models
  - model_name: claude-3-sonnet
    litellm_params:
      model: anthropic/claude-3-sonnet-20240229
      api_key: os.environ/ANTHROPIC_API_KEY

  # Local Ollama Models
  - model_name: llama2
    litellm_params:
      model: ollama/llama2
      api_base: http://homeassistant.local:11434

litellm_settings:
  drop_params: true
  set_verbose: false
  telemetry: false

general_settings:
  master_key: "your-master-key-here"
```

### Environment Variables

Set your API keys in Home Assistant's `secrets.yaml` or as environment variables:

```yaml
# In secrets.yaml
openai_api_key: "sk-your-openai-key"
anthropic_api_key: "sk-ant-your-anthropic-key"
```

Then reference them in your LiteLLM config:
```yaml
api_key: os.environ/OPENAI_API_KEY
```

## Usage

Once the add-on is running, you can access the LiteLLM Proxy API at:
- **API Endpoint**: `http://homeassistant.local:4000`
- **Health Check**: `http://homeassistant.local:4000/health`
- **API Documentation**: `http://homeassistant.local:4000/docs`

### Example API Call

```bash
curl -X POST "http://homeassistant.local:4000/v1/chat/completions" \
  -H "Authorization: Bearer your-master-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Integration with Home Assistant

You can use the LiteLLM Proxy with Home Assistant's conversation integration:

```yaml
# configuration.yaml
conversation:
  - platform: openai_conversation
    api_key: "your-master-key"
    base_url: "http://localhost:4000/v1"
    model: "gpt-3.5-turbo"
```

## Support

For issues and feature requests:
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)
- [Home Assistant Community](https://community.home-assistant.io/)

## License

This add-on is licensed under the Apache License 2.0.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg