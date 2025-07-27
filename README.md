# SwiftLangChain

SwiftLangChain is a composable framework for building AI agents, tools, and prompt chains on Apple platforms using LLMs like OpenAI, Claude, and local models.

## 🚀 Features

- 🤖 Build agents with tool-use reasoning
- 🔗 Chain prompts, LLMs, and output parsers
- 🧠 Plug-in memory and chat history
- ⚙️ Support multiple LLM providers (OpenAI, Claude, local)
- 🧪 Modular, testable, and async/await powered

## 📦 Installation

```swift
.package(url: "https://github.com/av-feaster/SwiftLangChain.git", from: "0.1.0")
```

## Folder Structure
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
│       │   ├── OpenAIProvider.swift     # OpenAI API wrapper
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
│           ├── ChatMessage.swift        # Roles: user, system, assistant
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
│   └── ChatWithMemory.swift             # Stateful memory-backed interaction
```
