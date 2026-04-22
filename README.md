# SwiftLangChain

[SwiftLangChain](https://forums.swift.org/t/swiftlangchain-is-here/81346) is a composable framework for building AI agents, tools, and prompt chains on Apple platforms using LLMs like OpenAI, Claude, and local models.

## 🚀 Features

- 🤖 Build agents with tool-use reasoning
- 🔗 Chain prompts, LLMs, and output parsers
- 🧠 Plug-in memory and chat history
- ⚙️ Support multiple LLM providers (OpenAI, Claude, Gemini, Cohere, Hugging Face, Core ML)
- 🖼️ Image message support for OpenAI GPT-4 Vision
- 🌊 Streaming responses for real-time output
- 🛠️ Function calling support for OpenAI
- 📱 Mobile-specific tools (Camera, Location, Contacts, Photos)
- 💾 Caching layer for improved performance
- 🔄 Retry logic with exponential backoff
- 🚦 Rate limiting for API requests
- 📊 Token counting and cost estimation
- 🧪 Modular, testable, and async/await powered

## 📦 Installation

```swift
.package(url: "https://github.com/av-feaster/SwiftLangChain.git", from: "0.1.0")
```

## 🖼️ Image Message Support

SwiftLangChain now supports image messages for OpenAI GPT-4 Vision models. You can send images along with text prompts for visual analysis and understanding.

### Supported Image Formats

The package supports **both** image URLs and base64-encoded images:

- **Image URLs**: Direct links to images on the web
- **Base64 Images**: Local images converted to base64 strings

### Basic Image Analysis (URL)

```swift
import SwiftLangChain

let openAI = OpenAIProvider(
    apiKey: "your-api-key-here",
    model: "gpt-4-vision-preview"
)

let memory = ContextMemory(
    maxTokens: 4000,
    maxMessages: 10,
    model: .gpt4
)

let conversation = ConversationChain(llm: openAI, memory: memory)

// Analyze image with text prompt
let response = try await conversation.runWithImage(
    "What do you see in this image?",
    imageUrl: "https://example.com/image.jpg",
    imageDetail: "high" // "low", "high", or "auto"
)

print(response)
```

### Base64 Image Analysis

```swift
// Convert local image to base64
let image = UIImage(named: "myImage")!
let base64String = ImageUtils.imageToBase64(image, format: .jpeg, quality: 0.8)

// Analyze base64 image with text prompt
let response = try await conversation.runWithBase64Image(
    "What do you see in this image?",
    imageBase64: base64String,
    imageDetail: "high"
)

// Or analyze base64 image only
let response = try await conversation.runWithBase64ImageOnly(
    base64String,
    imageDetail: "auto"
)
```

### Loading Images from URLs to Base64

```swift
// Load image from URL and convert to base64
let base64String = try await ImageUtils.urlStringToBase64(
    "https://example.com/image.jpg",
    format: .jpeg,
    quality: 0.8
)

// Use the base64 string
let response = try await conversation.runWithBase64Image(
    "Analyze this image",
    imageBase64: base64String
)
```

### Multiple Images in One Message

```swift
// Create a message with multiple content items
let textItem = ChatMessage.ContentItem(text: "Compare these images:")
let image1Item = ChatMessage.ContentItem(imageUrl: ChatMessage.ImageContent(url: "https://example.com/image1.jpg"))
let image2Item = ChatMessage.ContentItem(imageUrl: ChatMessage.ImageContent(base64: base64String))

let message = ChatMessage(
    role: .user,
    content: .mixed([textItem, image1Item, image2Item])
)

let messages: [ChatMessage] = [
    ChatMessage(role: .system, content: "You are a helpful assistant that can analyze and compare images."),
    message
]

let response = try await openAI.generateWithMessages(messages)
```

### Direct OpenAI Provider Usage

```swift
// Create messages with images
let messages: [ChatMessage] = [
    ChatMessage(role: .system, content: "You are a helpful assistant that can analyze images."),
    ChatMessage(
        role: .user,
        text: "What do you see in this image?",
        imageUrl: "https://example.com/image.jpg",
        imageDetail: "high"
    )
]

let response = try await openAI.generateWithMessages(messages)
```

### Image Detail Options

- `"low"`: Faster, less detailed analysis
- `"high"`: More detailed analysis (higher cost)
- `"auto"`: Let the model decide (recommended)

### Image Format Support

- **JPEG**: Good for photographs, smaller file sizes
- **PNG**: Good for graphics, supports transparency
- **Base64**: Any image format that can be encoded as base64

### Utility Functions

```swift
// Convert UIImage to base64
let base64 = ImageUtils.imageToBase64(image, format: .jpeg, quality: 0.8)

// Convert Data to base64
let base64 = ImageUtils.dataToBase64(imageData)

// Convert base64 back to UIImage
let image = ImageUtils.base64ToImage(base64String)

// Load image from URL and convert to base64
let base64 = try await ImageUtils.urlStringToBase64("https://example.com/image.jpg")
```

## 🤖 LLM Providers

SwiftLangChain supports multiple LLM providers:

### OpenAI

```swift
let openAI = OpenAIProvider(
    apiKey: "your-api-key",
    model: "gpt-4"
)
```

### Claude/Anthropic

```swift
let claude = AnthropicProvider(
    apiKey: "your-api-key",
    model: "claude-3-5-sonnet-20241022"
)
```

### Google Gemini

```swift
let gemini = GeminiProvider(
    apiKey: "your-api-key",
    model: "gemini-1.5-pro"
)
```

### Cohere

```swift
let cohere = CohereProvider(
    apiKey: "your-api-key",
    model: "command-r-plus"
)
```

### Hugging Face

```swift
let huggingFace = HuggingFaceProvider(
    apiKey: "your-api-key",
    model: "meta-llama/Llama-2-7b-chat-hf"
)
```

### Core ML (On-device)

```swift
let coreML = CoreMLProvider(
    modelName: "YourModel",
    fallbackProvider: openAI // Optional fallback to cloud
)
```

## 🌊 Streaming Responses

OpenAI provider supports streaming responses for real-time output:

```swift
let stream = try await openAI.generateStream(prompt: "Tell me a story")

for await chunk in stream {
    print(chunk.content)
    if chunk.isComplete {
        print("Stream complete")
    }
}
```

## 🛠️ Function Calling

OpenAI provider supports function calling:

```swift
let tool = MyFunctionTool()
let openAITool = OpenAITool(function: tool.functionDefinition)

let choice = try await openAI.generateWithTools(
    messages: [message],
    tools: [openAITool]
)

if let toolCall = choice.message.toolCalls?.first {
    let result = try await tool.executeWithArguments(
        try JSONSerialization.jsonObject(with: toolCall.function.arguments.data) as? [String: Any] ?? [:]
    )
}
```

## 📱 Mobile Tools

SwiftLangChain includes mobile-specific tools for iOS:

### Camera Tool

```swift
let cameraTool = CameraTool()
let photoData = try await cameraTool.execute("capture")
```

### Location Tool

```swift
let locationTool = LocationTool()
let location = try await locationTool.execute("get")
```

### Contacts Tool

```swift
let contactsTool = ContactsTool()
let contacts = try await contactsTool.execute("search")
```

### Photos Tool

```swift
let photosTool = PhotosTool()
let photos = try await photosTool.execute("list")
```

## 💾 Caching

Use the response cache to improve performance:

```swift
let cache = ResponseCache(policy: CachePolicy(maxAge: 3600, maxSize: 100))
let key = cache.generateKey(prompt: "Hello", parameters: nil)

if let cached = cache.get(key: key) {
    print("Cached: \(cached)")
} else {
    let response = try await llm.generate(prompt: "Hello")
    cache.set(key: key, value: response)
}
```

## 🔄 Retry Logic

Configure retry behavior:

```swift
let policy = RetryPolicy(
    maxAttempts: 3,
    backoffStrategy: .exponential,
    jitter: true
)
```

## 🚦 Rate Limiting

Use rate limiting to prevent API throttling:

```swift
let limiter = RateLimiter(maxTokens: 100, refillRate: 10)

if limiter.tryConsume() {
    // Make API request
} else {
    // Wait for token refill
    await limiter.waitForToken()
}
```

## 📊 Token Counting

Track token usage and costs:

```swift
let counter = TokenCounter(model: .gpt4)
let tokens = counter.countTokens(in: "Hello, world!")
let cost = counter.estimateCost(tokens: tokens, model: .gpt4)

let tracker = TokenUsageTracker()
await tracker.trackUsage(sessionId: "session-1", promptTokens: 100, completionTokens: 50, model: .gpt4)
```

## 📁 Folder Structure
```
SwiftLangChain/
├── Package.swift                        # Swift Package manifest
├── README.md                            # Project overview and usage
├── LICENSE                              # Open-source license (MIT, Apache 2.0 etc.)
├── .gitignore                           # Standard Swift ignores
├── Sources/
│   └── SwiftLangChain/
│       ├── SwiftLangChain.swift         # Re-export or glue file (empty or entry-point)

│       ├── Prompt/
│       │   ├── PromptTemplate.swift     # Template with variables: "Hello, {name}"
│       │   └── PromptValue.swift        # Optional: encapsulates pre-filled template

│       ├── LLMProvider/
│       │   ├── LLMProvider.swift        # Protocol (generate(prompt:) async -> String)
│       │   ├── OpenAI/                  # OpenAI provider with streaming and function calling
│       │   │   ├── OpenAIProvider.swift
│       │   │   ├── OpenAIRequest.swift
│       │   │   └── FunctionCalling.swift
│       │   ├── Anthropic/               # Claude/Anthropic provider
│       │   │   ├── AnthropicProvider.swift
│       │   │   └── AnthropicRequest.swift
│       │   ├── Gemini/                  # Google Gemini provider
│       │   │   ├── GeminiProvider.swift
│       │   │   └── GeminiRequest.swift
│       │   ├── Cohere/                  # Cohere provider
│       │   │   ├── CohereProvider.swift
│       │   │   └── CohereRequest.swift
│       │   ├── HuggingFace/             # Hugging Face provider
│       │   │   ├── HuggingFaceProvider.swift
│       │   │   └── HuggingFaceRequest.swift
│       │   └── CoreML/                  # Core ML on-device provider
│       │       ├── CoreMLProvider.swift
│       │       └── CoreMLModelLoader.swift

│       ├── Chain/
│       │   ├── Chain.swift               # Protocol for all chains
│       │   ├── SequentialChain.swift    # Runs multiple chains step-by-step
│       │   └── ConversationChain.swift  # Chat-based chain with memory

│       ├── Memory/
│       │   ├── ChatMessage.swift        # Message roles and content (with image support)
│       │   └── ContextMemory.swift      # Rolling memory or token-limited

│       ├── Tools/                       # Tool protocol and implementations
│       │   ├── Tool.swift               # Tool protocol
│       │   ├── FunctionTool.swift       # Function calling support
│       │   └── Mobile/                  # Mobile-specific tools
│       │       ├── CameraTool.swift
│       │       ├── LocationTool.swift
│       │       ├── ContactsTool.swift
│       │       └── PhotosTool.swift

│       ├── Utils/
│       │   ├── Cache/                   # Caching layer
│       │   │   ├── ResponseCache.swift
│       │   │   └── CachePolicy.swift
│       │   ├── Retry/                   # Retry logic
│       │   │   ├── RetryPolicy.swift
│       │   │   └── RetryableError.swift
│       │   ├── RateLimit/               # Rate limiting
│       │   │   └── RateLimiter.swift
│       │   ├── Tokenizer/               # Token counting
│       │   │   └── TokenCounter.swift
│       │   └── NetworkClient.swift       # HTTP client for API requests

│       └── Agent/
│           └── ConversationalAgent.swift # Agent with tool use

├── Tests/
│   └── SwiftLangChainTests/
│       ├── PromptTemplateTests.swift
│       ├── LLMChainTests.swift
│       ├── Mocks/
│       │   └── MockLLMProvider.swift    # Dummy provider for deterministic unit tests
│       └── TestUtils.swift              # Helpers for testing

├── Examples/                            # Playground-style demo code (if any)
│   ├── HelloLangChain.swift             # Simple chain: "Hello, {name}"
│   ├── ChatWithMemory.swift             # Stateful memory-backed interaction
│   └── ImageExample.swift               # Image message examples
```
