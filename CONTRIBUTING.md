# Contributing to SwiftLangChain

Thank you for your interest in contributing to SwiftLangChain!

## � Development Setup

### Prerequisites

- macOS 15.0 or later
- Xcode 16.0 or later
- Swift 5.9 or later

### Building

```bash
# Build the Swift package
swift build

# Build the sample app
cd sample-app
xcodebuild -project sample-app.xcodeproj -scheme sample-app -configuration Debug
```

### Running Tests

```bash
swift test
```

## 📝 Code Style Guidelines

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation
- Add documentation comments for public APIs
- Keep lines under 120 characters

### Documentation Example

```swift
/// Fetches available models from the provider's API
/// - Returns: An array of ModelInfo objects
/// - Throws: NetworkError if the request fails
public func fetchModels() async throws -> [ModelInfo] {
    // Implementation
}
```

## 🧪 Testing

Add tests for new functionality in the `Tests/swiftlangchainTests/` directory.

## 📤 Submitting Changes

### Commit Messages

Use conventional commit format:
```
feat: add Perplexity provider support
fix: resolve streaming response issue
docs: update installation instructions
```

### Pre-commit Hook

The project includes a pre-commit hook that automatically builds the package and sample app before committing.

### Pull Request Process

1. Create a new branch from `main`
2. Make your changes
3. Ensure the build passes
4. Submit a pull request with a clear description

## 🐛 Reporting Issues

Include:
- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Environment (macOS, Xcode, Swift versions)
- Code sample if applicable

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.
