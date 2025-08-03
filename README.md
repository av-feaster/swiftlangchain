# SwiftLangChain

[SwiftLangChain](https://forums.swift.org/t/swiftlangchain-is-here/81346) is a composable framework for building AI agents, tools, and prompt chains on Apple platforms using LLMs like OpenAI, Claude, and local models.

## 🚀 Features

- 🤖 Build agents with tool-use reasoning
- 🔗 Chain prompts, LLMs, and output parsers
- 🧠 Plug-in memory and chat history
- ⚙️ Support multiple LLM providers (OpenAI, Claude, local)
- 🖼️ **NEW: Image message support for OpenAI GPT-4 Vision**
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
│
│       ├── Prompt/
│       │   ├── PromptTemplate.swift     # Template with variables: "Hello, {name}"
│       │   └── PromptValue.swift        # Optional: encapsulates pre-filled template
│
│       ├── LLMProvider/
│       │   ├── LLMProvider.swift        # Protocol (generate(prompt:) async -> String)
│       │   ├── OpenAIProvider.swift     # OpenAI API wrapper with image support
│       │   ├── MLCProvider.swift        # Wrapper for MLC-LLM
│       │   └── LlamaCppProvider.swift   # llama.cpp integration via local server
│
│       ├── Chain/
│       │   ├── LLMChain.swift           # Basic chain: PromptTemplate + LLMProvider
│       │   ├── SequentialChain.swift    # Runs multiple chains step-by-step
│       │   └── ChainProtocol.swift      # Protocol for all chains
│
│       ├── Memory/
│       │   └── ConversationMemory.swift # Rolling memory or token-limited
│
│       ├── Tools/                       # Optional: wrappers for search, APIs, etc.
│       │   └── Tool.swift               # Defines tool protocol (e.g., Calculator, API)
│
│       ├── Utils/
│       │   ├── Tokenizer.swift          # Optional: token counting
│       │   └── Logger.swift             # Print/debug logs
│
│       └── Schema/
│           ├── ChatMessage.swift        # Roles: user, system, assistant (with image support)
│           └── OutputParser.swift       # If returning structured data
│
├── Tests/
│   └── SwiftLangChainTests/
│       ├── PromptTemplateTests.swift
│       ├── LLMChainTests.swift
│       ├── Mocks/
│       │   └── MockLLMProvider.swift    # Dummy provider for deterministic unit tests
│       └── TestUtils.swift              # Helpers for testing
│
├── Examples/                            # Playground-style demo code (if any)
│   ├── HelloLangChain.swift             # Simple chain: "Hello, {name}"
│   ├── ChatWithMemory.swift             # Stateful memory-backed interaction
│   └── ImageExample.swift               # Image message examples
```
