//
//  Tokenizer.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

public struct Tokenizer {
    /// Estimate token count based on average chars per token
    public static func estimateTokenCount(_ text: String, model: LLMModel = .gpt4) -> Int {
        return text.count / model.estimatedCharactersPerToken
    }
    
    /// Truncate text to fit within token limit
    public static func truncateToTokenLimit(
        _ text: String,
        maxTokens: Int,
        model: LLMModel = .gpt4
    ) -> String {
        let maxChars = maxTokens * model.estimatedCharactersPerToken
        return String(text.prefix(maxChars))
    }
}
