//
//  ContextMemory.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


/// Aggregates chat messages and trims context based on token/message limits
public struct ContextMemory {
    private var messages: [ChatMessage] = []
    private let maxTokens: Int?
    private let maxMessages: Int?
    private let currentModel: LLMModel

    public init(maxTokens: Int? = nil, maxMessages: Int? = nil, model: LLMModel) {
        self.maxTokens = maxTokens
        self.maxMessages = maxMessages
        self.currentModel = model
    }

    /// Add a message to memory and trim context if needed
    public mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
        trimIfNeeded()
    }

    /// Get all messages currently in memory
    public func getMessages() -> [ChatMessage] {
        return messages
    }

    /// Clear all memory
    public mutating func clear() {
        messages.removeAll()
    }

    /// Format memory into a single string prompt
    public func asPromptContext() -> String {
        messages
            .map { "\($0.role.rawValue): \($0.content)" }
            .joined(separator: "\n")
    }

    /// Get the most recent user message
    public func lastUserMessage() -> ChatMessage? {
        messages.last(where: { $0.role == .user })
    }

    /// Trims context by message count and estimated tokens
    private mutating func trimIfNeeded() {
        if let maxMessages = maxMessages, messages.count > maxMessages {
            messages = Array(messages.suffix(maxMessages))
        }

        if let maxTokens = maxTokens {
            var totalTokens = 0
            var trimmed: [ChatMessage] = []

            for message in messages.reversed() {
                let tokenCount = Tokenizer.estimateTokenCount(message.content, model: currentModel)
                if totalTokens + tokenCount > maxTokens { break }
                trimmed.insert(message, at: 0)
                totalTokens += tokenCount
            }

            messages = trimmed
        }
    }
}
