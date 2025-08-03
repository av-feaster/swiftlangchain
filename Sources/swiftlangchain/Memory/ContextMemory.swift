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
            .compactMap { message in
                guard let textContent = message.textContent else { return nil }
                return "\(message.role.rawValue): \(textContent)"
            }
            .joined(separator: "\n")
    }

    /// Get the most recent user message
    public func lastUserMessage() -> ChatMessage? {
        messages.last(where: { $0.role == .user })
    }

    /// Trims context by message count and estimated tokens
    private mutating func trimIfNeeded() {
        // Trim by message count if needed
        if let maxMessages = maxMessages, messages.count > maxMessages {
            let excess = messages.count - maxMessages
            messages.removeFirst(excess)
        }
        
        // Trim by token count if needed
        if let maxTokens = maxTokens {
            var totalTokens = 0
            var trimmedMessages: [ChatMessage] = []
            
            // Start from the most recent messages
            for message in messages.reversed() {
                let messageTokens = estimateTokens(for: message)
                if totalTokens + messageTokens <= maxTokens {
                    trimmedMessages.insert(message, at: 0)
                    totalTokens += messageTokens
                } else {
                    break
                }
            }
            
            messages = trimmedMessages
        }
    }
    
    /// Estimate tokens for a message
    private func estimateTokens(for message: ChatMessage) -> Int {
        var tokenCount = 0
        
        // Count text tokens
        if let textContent = message.textContent {
            tokenCount += textContent.components(separatedBy: .whitespacesAndNewlines).count
        }
        
        // Count image tokens (rough estimate: 1 image ≈ 85 tokens for gpt-4-vision)
        let imageCount = message.imageUrls.count
        tokenCount += imageCount * 85
        
        return tokenCount
    }
}
