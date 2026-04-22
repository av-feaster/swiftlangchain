//
//  TokenCounter.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Token counter for estimating token usage
public struct TokenCounter {
    private let model: LLMModel
    
    public init(model: LLMModel = .gpt3) {
        self.model = model
    }
    
    /// Count tokens in a text string (approximate)
    public func countTokens(in text: String) -> Int {
        // This is a simplified implementation
        // Real implementation would use model-specific tokenizers (tiktoken, etc.)
        let estimatedCharactersPerToken = model.estimatedCharactersPerToken
        return Int(ceil(Double(text.count) / Double(estimatedCharactersPerToken)))
    }
    
    /// Count tokens in ChatMessages
    public func countTokens(in messages: [ChatMessage]) -> Int {
        var totalTokens = 0
        
        for message in messages {
            switch message.content {
            case .text(let text):
                totalTokens += countTokens(in: text)
            case .image(let imageContent):
                // Images typically cost more tokens
                totalTokens += 85 // Approximate token cost for images
                if let url = imageContent.url {
                    totalTokens += countTokens(in: url)
                }
            case .mixed(let items):
                for item in items {
                    if let text = item.text {
                        totalTokens += countTokens(in: text)
                    }
                    if let imageUrl = item.imageUrl {
                        totalTokens += 85
                        if let url = imageUrl.url {
                            totalTokens += countTokens(in: url)
                        }
                    }
                }
            }
        }
        
        return totalTokens
    }
    
    /// Estimate token cost for a model
    public func estimateCost(tokens: Int, model: LLMModel = .gpt3) -> Double {
        // Pricing per 1M tokens (approximate USD)
        let pricing: [LLMModel: (input: Double, output: Double)] = [
            .gpt3: (0.5, 1.5),
            .gpt4: (30.0, 60.0),
            .mistral: (0.15, 0.15),
            .custom(let cpt): (Double(cpt), Double(cpt))
        ]
        
        guard let (inputPrice, _) = pricing[model] else {
            return 0
        }
        
        return (Double(tokens) / 1_000_000) * inputPrice
    }
}

/// Token usage statistics
public struct TokenUsageStatistics {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    public let estimatedCost: Double
    
    public init(promptTokens: Int = 0, completionTokens: Int = 0, model: LLMModel = .gpt3) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = promptTokens + completionTokens
        
        let counter = TokenCounter(model: model)
        self.estimatedCost = counter.estimateCost(tokens: totalTokens, model: model)
    }
    
    /// Get cost breakdown
    public func getCostBreakdown(model: LLMModel = .gpt3) -> (promptCost: Double, completionCost: Double) {
        let counter = TokenCounter(model: model)
        let promptCost = counter.estimateCost(tokens: promptTokens, model: model)
        let completionCost = counter.estimateCost(tokens: completionTokens, model: model)
        return (promptCost, completionCost)
    }
}

/// Token usage tracker
public actor TokenUsageTracker {
    private var sessionTokens: [String: TokenUsageStatistics] = [:]
    private var totalUsage: TokenUsageStatistics
    
    public init() {
        self.totalUsage = TokenUsageStatistics()
    }
    
    /// Track token usage for a session
    public func trackUsage(sessionId: String, promptTokens: Int, completionTokens: Int, model: LLMModel = .gpt3) {
        let stats = TokenUsageStatistics(promptTokens: promptTokens, completionTokens: completionTokens, model: model)
        sessionTokens[sessionId] = stats
        
        // Update total usage
        totalUsage = TokenUsageStatistics(
            promptTokens: totalUsage.promptTokens + promptTokens,
            completionTokens: totalUsage.completionTokens + completionTokens,
            model: model
        )
    }
    
    /// Get usage for a specific session
    public func getSessionUsage(sessionId: String) -> TokenUsageStatistics? {
        return sessionTokens[sessionId]
    }
    
    /// Get total usage across all sessions
    public func getTotalUsage() -> TokenUsageStatistics {
        return totalUsage
    }
    
    /// Clear session data
    public func clearSession(sessionId: String) {
        sessionTokens.removeValue(forKey: sessionId)
    }
    
    /// Clear all session data
    public func clearAllSessions() {
        sessionTokens.removeAll()
        totalUsage = TokenUsageStatistics()
    }
}
