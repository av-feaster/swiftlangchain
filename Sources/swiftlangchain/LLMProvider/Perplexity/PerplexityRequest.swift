//
//  PerplexityRequest.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Perplexity Request Structures

/// Perplexity API message
public struct PerplexityMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

/// Perplexity API request body
public struct PerplexityRequest: Codable {
    public let model: String
    public let messages: [PerplexityMessage]
    public let stream: Bool?
    public let maxTokens: Int?
    public let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, stream
        case maxTokens = "max_tokens"
        case temperature
    }
    
    public init(
        model: String,
        messages: [PerplexityMessage],
        stream: Bool? = false,
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) {
        self.model = model
        self.messages = messages
        self.stream = stream
        self.maxTokens = maxTokens
        self.temperature = temperature
    }
}
