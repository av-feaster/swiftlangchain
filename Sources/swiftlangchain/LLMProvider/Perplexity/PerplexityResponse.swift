//
//  PerplexityResponse.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Perplexity Response Structures

/// Perplexity API message in response
public struct PerplexityResponseMessage: Codable {
    public let role: String
    public let content: String
}

/// Perplexity API choice
public struct PerplexityChoice: Codable {
    public let index: Int
    public let message: PerplexityResponseMessage
    public let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

/// Perplexity API usage
public struct PerplexityUsage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

/// Perplexity API response
public struct PerplexityResponse: Codable {
    public let id: String
    public let model: String
    public let choices: [PerplexityChoice]
    public let usage: PerplexityUsage?
    public let created: Int?
}

/// Perplexity streaming chunk
public struct PerplexityStreamChunk: Codable {
    public let id: String
    public let model: String
    public let choices: [PerplexityStreamChoice]
    public let created: Int?
}

/// Perplexity streaming choice
public struct PerplexityStreamChoice: Codable {
    public let index: Int
    public let delta: PerplexityStreamDelta
    public let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, delta
        case finishReason = "finish_reason"
    }
}

/// Perplexity streaming delta
public struct PerplexityStreamDelta: Codable {
    public let role: String?
    public let content: String
}

/// Perplexity error response
public struct PerplexityErrorResponse: Codable {
    public let error: PerplexityErrorDetail
}

/// Perplexity error detail
public struct PerplexityErrorDetail: Codable {
    public let message: String
    public let type: String?
    public let code: Int?
}

// MARK: - Perplexity Models API

/// Perplexity Models Response
public struct PerplexityModelsResponse: Codable {
    public let models: [PerplexityModel]
}

/// Perplexity Model
public struct PerplexityModel: Codable {
    public let name: String
    public let displayName: String?
    public let type: String?
    public let contextLength: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, type
        case displayName = "display_name"
        case contextLength = "context_length"
    }
}
