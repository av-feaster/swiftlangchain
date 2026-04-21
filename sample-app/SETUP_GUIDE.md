# Environment Configuration Setup Guide

## Overview

The SwiftLangChain sample app uses environment variables for secure API key management. This guide shows how to configure your OpenAI API key.

## Files Created

1. **Config.xcconfig** - Build configuration template (committed to git)
2. **Config.xcconfig.local** - Local configuration with actual API keys (gitignored)
3. **Config.swift** - Configuration manager that reads from multiple sources

## Configuration Methods

### Method 1: Using Xcode Scheme (Recommended for Development)

1. Open `sample-app.xcodeproj` in Xcode
2. Product → Scheme → Edit Scheme... (⌘+<)
3. Select "Run" from the left sidebar
4. Click the "Environment Variables" tab
5. Click the "+" button to add:
   - Name: `OPENAI_API_KEY`
   - Value: `your-actual-openai-api-key`
6. Click "Close"

### Method 2: Using Info.plist

1. Open `sample-app/Info.plist` in the sample app target
2. Add the following keys:
   ```xml
   <key>OPENAI_API_KEY</key>
   <string>your-actual-openai-api-key</string>
   <key>OPENAI_MODEL</key>
   <string>gpt-3.5-turbo</string>
   <key>MAX_TOKENS</key>
   <integer>4000</integer>
   <key>MAX_MESSAGES</key>
   <integer>10</integer>
   ```
3. **Important**: Add these keys to your `.gitignore` or use a separate `Info-local.plist`

### Method 3: Using Config.xcconfig.local

1. Edit `sample-app/Config.xcconfig.local`
2. Replace `your-actual-openai-api-key` with your real API key
3. In Xcode:
   - Select the project file in navigator
   - Select the "sample-app" target
   - Go to "Build Settings" tab
   - Search for "Config File"
   - Set "Config File" to `Config.xcconfig.local`

### Method 4: Using Command Line Environment Variables

When running from command line:
```bash
OPENAI_API_KEY=your-key xcodebuild -scheme sample-app
```

## Config.swift Priority Order

The `Config` struct reads configuration in this priority order:

1. **Environment Variables** (highest priority) - Set in Xcode scheme or command line
2. **Info.plist** - Bundle configuration
3. **Fallback Defaults** - Hardcoded in Config.swift

## Security Best Practices

### For Development
- Use Xcode scheme environment variables (Method 1)
- Never commit actual API keys to git
- Use `Config.xcconfig.local` for local development (already in .gitignore)

### For Production
- Use backend proxy for API calls
- Implement proper authentication
- Use Keychain Services for secure storage
- Never embed API keys in the app bundle

### For CI/CD
- Use secret management (GitHub Secrets, GitLab CI variables, etc.)
- Inject environment variables during build
- Rotate API keys regularly

## Verification

To verify your configuration is working:

1. Build and run the app
2. The app should load without errors
3. Try sending a message
4. If you see "Error: API key is not configured", check your setup

## Troubleshooting

### API Key Not Found
- Verify the environment variable name matches exactly: `OPENAI_API_KEY`
- Check that you're using the correct scheme in Xcode
- Clean build folder (⌘+Shift+K) and rebuild

### Build Errors
- Ensure Config.swift is added to the target
- Verify no syntax errors in Config.xcconfig files
- Check that all required files are in the project

### Runtime Errors
- Verify your OpenAI API key is valid and has credits
- Check network connectivity
- Ensure the model name is correct (e.g., `gpt-3.5-turbo`)

## Getting an OpenAI API Key

1. Go to https://platform.openai.com/api-keys
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the key (you won't see it again)
5. Add it to your configuration using one of the methods above

## Additional Configuration Options

You can also configure these optional parameters:

- `OPENAI_MODEL`: Model to use (default: `gpt-3.5-turbo`)
- `MAX_TOKENS`: Maximum tokens for context memory (default: 4000)
- `MAX_MESSAGES`: Maximum messages in memory (default: 10)

Example:
```bash
OPENAI_API_KEY=sk-xxx
OPENAI_MODEL=gpt-4
MAX_TOKENS=8000
MAX_MESSAGES=20
```
