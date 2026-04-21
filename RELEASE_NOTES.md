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
