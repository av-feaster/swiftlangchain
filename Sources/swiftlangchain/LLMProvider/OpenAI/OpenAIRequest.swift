//
//  OpenAIRequest.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


//
//  OpenAIModels.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

// MARK: - OpenAI API Request Models

/// OpenAI Chat Completion Request
public struct OpenAIRequest: Codable {
    public let model: String
    public let messages: [OpenAIMessage]
    public let temperature: Double?
    public let maxTokens: Int?
    public let topP: Double?
    public let frequencyPenalty: Double?
    public let presencePenalty: Double?
    
    public init(
        model: String,
        messages: [OpenAIMessage],
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        topP: Double? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
    }
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
        case topP = "top_p"
        case frequencyPenalty = "frequency_penalty"
        case presencePenalty = "presence_penalty"
    }
}

/// OpenAI Message
public struct OpenAIMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

// MARK: - OpenAI API Response Models

/// OpenAI Chat Completion Response
public struct OpenAIResponse: Codable {
    public let id: String
    public let object: String
    public let created: Int
    public let model: String
    public let choices: [OpenAIChoice]
    public let usage: OpenAIUsage
}

/// OpenAI Choice
public struct OpenAIChoice: Codable {
    public let index: Int
    public let message: OpenAIMessage
    public let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

/// OpenAI Usage
public struct OpenAIUsage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - OpenAI Error Response

/// OpenAI Error Response
public struct OpenAIErrorResponse: Codable {
    public let error: OpenAIError
}

/// OpenAI Error
public struct OpenAIError: Codable {
    public let message: String
    public let type: String?
    public let code: String?
}


// MARK: - OpenAI Custom Errors

public enum OpenAICustomError: Error, LocalizedError {
    case custom(message: String, statusCode: Int)
    case invalidAPIKey
    case rateLimitExceeded
    case quotaExceeded
    
    public var errorDescription: String? {
        switch self {
        case .custom(let message, let statusCode):
            return "OpenAI API Error (\(statusCode)): \(message)"
        case .invalidAPIKey:
            return "Invalid OpenAI API key"
        case .rateLimitExceeded:
            return "OpenAI rate limit exceeded"
        case .quotaExceeded:
            return "OpenAI quota exceeded"
        }
    }
}
