//
//  CohereRequest.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Cohere Request Structures

public struct CohereMessage: Codable {
    public let role: String
    public let content: String
    
    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public struct CohereRequestBody: Codable {
    public let message: String
    public let chat_history: [CohereMessage]?
    public let model: String
    public let temperature: Double?
    public let p: Double?
    public let k: Int?
    public let max_tokens: Int?
    
    public init(
        message: String,
        chatHistory: [CohereMessage]? = nil,
        model: String,
        temperature: Double? = nil,
        p: Double? = nil,
        k: Int? = nil,
        maxTokens: Int? = nil
    ) {
        self.message = message
        self.chat_history = chatHistory
        self.model = model
        self.temperature = temperature
        self.p = p
        self.k = k
        self.max_tokens = maxTokens
    }
}

// MARK: - Cohere Response Structures

public struct CohereResponse: Codable {
    public let text: String
    public let generation_id: String
    public let finish_reason: String?
    public let meta: CohereMeta?
}

public struct CohereMeta: Codable {
    public let api_version: String?
    public let billed_units: String?
}

public struct CohereErrorResponse: Codable {
    public let message: String
    public let statusCode: Int?
}

public enum CohereCustomError: Error, LocalizedError {
    case custom(message: String, statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .custom(let message, _):
            return message
        }
    }
}

// MARK: - Cohere Models API

/// Cohere Models Response
public struct CohereModelsResponse: Codable {
    public let models: [CohereModel]
}

/// Cohere Model
public struct CohereModel: Codable {
    public let id: String
    public let name: String
    public let contextLength: Int?
    public let endpoints: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, endpoints
        case contextLength = "context_length"
    }
}
