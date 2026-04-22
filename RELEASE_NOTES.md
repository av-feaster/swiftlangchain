## v0.3.0 - Major Feature Release: Multiple Providers, Streaming, and Advanced Features

### Features Added

#### LLM Providers
- **Claude/Anthropic Provider**: Added AnthropicProvider with message API support
- **Google Gemini Provider**: Added GeminiProvider with multimodal support
- **Cohere Provider**: Added CohereProvider with chat endpoint
- **Hugging Face Provider**: Added HuggingFaceProvider with inference API
- **Core ML Integration**: Added CoreMLProvider for on-device inference with fallback support

#### Streaming & Functionality
- **Streaming Responses**: Added StreamingLLMProvider protocol with AsyncStream support
- **Function Calling**: Added OpenAI function calling with FunctionTool protocol
- **FunctionDefinitionBuilder**: Builder for creating function schemas

#### Mobile Tools
- **CameraTool**: Photo capture using AVFoundation
- **LocationTool**: Geolocation using CoreLocation
- **ContactsTool**: Address book access using Contacts framework
- **PhotosTool**: Photo library access using Photos framework

#### Performance & Reliability
- **Caching Layer**: ResponseCache with in-memory and persistent storage
- **CachePolicy**: Time-based, size-based, and LRU eviction policies
- **Retry Logic**: RetryPolicy with exponential backoff and jitter
- **Circuit Breaker**: Pattern for preventing cascading failures
- **Rate Limiting**: Token bucket and sliding window rate limiters

#### Monitoring & Cost
- **Token Counting**: TokenCounter for usage tracking
- **Cost Estimation**: Model-specific cost calculation
- **TokenUsageTracker**: Session-based usage tracking

#### Documentation
- Updated README.md with all new features and providers
- Updated folder structure documentation
- Added usage examples for all new features

#### Sample App
- Added provider selection (OpenAI, Claude, Gemini, Cohere)
- Added token usage and cost estimation display
- Updated feature showcase with all new capabilities

### Platform Support
- Added platform declarations (iOS 13+, macOS 10.15+)
- Added default localization language

### Breaking Changes
- None - all changes are additive

### Migration Guide
No migration required. All new features are opt-in and backward compatible.

### Getting Started
See [README.md](README.md) for updated documentation and usage examples

---

## v0.2.0 - Sample App Integration and Environment Configuration

### Features Added
- **Sample iOS App**: Added SwiftUI-based sample app demonstrating SwiftLangChain usage
- **Environment Configuration**: Added Config.swift for secure API key management
- **Build Configuration**: Added Config.xcconfig for build-time configuration
- **Documentation**: 
  - CODEMAP.md - Complete package structure and dependency map
  - INTEGRATION_GUIDE.md - Step-by-step integration instructions
  - SETUP_GUIDE.md - Environment configuration setup guide

### Bug Fixes
- Fixed optional unwrapping error in OpenAIProvider.swift
- Updated swiftlangchain.swift with comprehensive API documentation

### Configuration
- Updated .gitignore to exclude local config files (Config.xcconfig.local)
- Added support for environment variables, Info.plist, and build configurations

### Getting Started
See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for integration instructions
See [SETUP_GUIDE.md](sample-app/SETUP_GUIDE.md) for environment setup
