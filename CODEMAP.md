# SwiftLangChain Code Map

## Package Structure

```
swiftlangchain/
├── Package.swift                          # SPM manifest
├── Sources/
│   └── swiftlangchain/
│       ├── swiftlangchain.swift           # Main entry point (modified)
│       ├── Agent/                         # Agent implementations
│       │   ├── AgentBuilder.swift        # Builder pattern for agents
│       │   ├── ConversationalAgent.swift  # Conversational agent with memory
│       │   ├── MultiAgent.swift          # Multi-agent coordination
│       │   ├── PlanAndExecuteAgent.swift # Planning agent
│       │   └── ReActAgent.swift          # ReAct reasoning agent
│       ├── Chain/                         # Chain implementations
│       │   ├── Chain.swift               # Chain protocol
│       │   ├── ConversationChain.swift   # Conversation chain with memory
│       │   ├── LLMChain.swift            # Basic LLM chain
│       │   └── SequentialChain.swift     # Sequential chain composition
│       ├── LLMProvider/                   # LLM provider implementations
│       │   ├── LLMProvider.swift         # Provider protocol
│       │   ├── LLMModel.swift            # Model enums
│       │   └── OpenAI/
│       │       ├── OpenAIProvider.swift  # OpenAI API implementation
│       │       └── OpenAIRequest.swift   # Request/response types
│       ├── Memory/                        # Memory implementations
│       │   ├── ChatMessage.swift         # Message types with image support
│       │   └── ContextMemory.swift       # Context memory management
│       ├── Prompt/                        # Prompt templates
│       │   ├── PromptTemplate.swift      # Template engine
│       │   └── PromptValue.swift         # Pre-filled templates
│       ├── Tools/                         # Tool implementations
│       │   ├── Tool.swift                # Tool protocol
│       │   ├── CalculatorTool.swift      # Calculator tool
│       │   └── SearchTool.swift          # Search tool
│       ├── Utils/                         # Utilities
│       │   ├── ImageUtils.swift          # Image processing
│       │   ├── OutputParser.swift        # Output parsing
│       │   └── Tokenizer.swift           # Token counting
│       ├── NetworkClient/                 # Network layer
│       │   └── NetworkClient.swift        # HTTP client
│       └── Examples/                      # Example implementations
│           ├── ImageExample.swift
│           └── SimpleImageExample.swift
└── sample-app/                           # Sample iOS app
    └── sample-app/
        ├── sample_appApp.swift
        └── ContentView.swift
```

## Key Components and Dependencies

### LLMProvider Layer
```
LLMProvider (protocol)
├── GenerationParameters
├── LLMModel (enum)
└── OpenAIProvider (implements LLMProvider)
    └── OpenAIRequest (request/response types)
```

### Chain Layer
```
Chain (protocol)
├── CombinableChain (protocol)
├── LLMChain (implements Chain, CombinableChain)
├── ConversationChain (implements Chain, CombinableChain)
└── SequentialChain (combines two chains)
```

### Agent Layer
```
Agent (protocol)
├── CombinableAgent (protocol)
├── ConversationalAgent (implements CombinableAgent)
├── ReActAgent (implements Agent, CombinableAgent)
├── PlanAndExecuteAgent (implements Agent, CombinableAgent)
├── MultiAgent (combines two agents)
└── AgentBuilder (builder pattern)
```

### Memory Layer
```
ChatMessage (struct with image support)
└── ContextMemory (manages conversation history)
```

### Tool Layer
```
Tool (protocol)
├── ChainableTool (protocol)
├── AuthenticatedTool (protocol)
├── RateLimitedTool (protocol)
├── ChainedTool (combines two tools)
├── ToolRegistry (actor for tool management)
├── CalculatorTool (implements Tool)
└── SearchTool (implements Tool)
```

### Utility Layer
```
Tokenizer
├── ImageUtils
└── OutputParser
    ├── JSONOutputParser
    └── TextOutputParser
```

## Integration Points

### For Sample App Integration

The sample app needs to:

1. **Add Package Dependency**: Add swiftlangchain as a local package dependency in Xcode
2. **Import Module**: `import SwiftLangChain`
3. **Use Components**: Access any of the public types directly

### Key Public APIs

```swift
// LLM Provider
let provider = OpenAIProvider(apiKey: "key", model: "gpt-4")

// Chains
let chain = LLMChain(promptTemplate: template, llmProvider: provider)
let conversationChain = ConversationChain(llm: provider, memory: memory)

// Agents
let agent = ConversationalAgent(llm: provider, tools: [tool])

// Memory
let memory = ContextMemory(maxTokens: 4000, maxMessages: 10)
let message = ChatMessage(role: .user, content: "Hello")

// Tools
let tool = CalculatorTool()
```

## Modifications Made to Sources

### swiftlangchain.swift
- Added comprehensive documentation listing all available public components
- Removed self-referential typealiases (they're not needed in Swift)
- Added clear documentation of what's available when importing the module

## Sample App Integration Steps

1. Open sample-app.xcodeproj
2. Add swiftlangchain as a local package dependency
3. In ContentView.swift, add: `import SwiftLangChain`
4. Use the components to build a demo UI

## Dependencies

- Foundation (standard library)
- No external dependencies (uses URLSession for networking)
