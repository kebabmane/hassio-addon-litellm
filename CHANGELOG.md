# Changelog

All notable changes to this Home Assistant add-on will be documented in this file.

## [1.0.0] - 2025-01-07

### Added
- Initial release of LiteLLM Proxy Home Assistant add-on
- Support for 100+ LLM providers through unified OpenAI-compatible API
- Configurable port and YAML configuration file
- Master key authentication support
- Automatic default configuration generation
- Support for all major architectures (amd64, aarch64, armv7, armhf, i386)
- Comprehensive documentation and examples
- Integration examples for Home Assistant conversation

### Features
- **Universal LLM API**: Call OpenAI, Anthropic, Azure, Ollama, and 100+ other providers
- **Load Balancing**: Distribute requests across multiple models
- **Cost Tracking**: Monitor usage and costs
- **Caching**: Redis-based response caching support
- **Authentication**: API key management
- **Observability**: Detailed logging and metrics

### Configuration Options
- `port`: Configurable API port (default: 4000)
- `config_file`: Custom YAML configuration file
- `log_level`: Adjustable logging levels (DEBUG, INFO, WARNING, ERROR)
- `master_key`: Optional authentication key

### Supported Providers
- OpenAI (GPT-3.5, GPT-4, etc.)
- Anthropic (Claude models)
- Azure OpenAI
- Ollama (local models)
- Google AI Studio
- AWS Bedrock
- And 95+ more providers

### Documentation
- Complete setup and configuration guide
- API usage examples
- Home Assistant integration examples
- Troubleshooting guide