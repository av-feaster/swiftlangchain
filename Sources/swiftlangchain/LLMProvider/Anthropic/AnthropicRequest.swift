//
//  AnthropicRequest.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Anthropic Request Structures

public struct AnthropicMessage: Codable {
    public let role: String
    public let content: AnthropicContent
    
    public init(role: String, content: AnthropicContent) {
        self.role = role
        self.content = content
    }
}

public enum AnthropicContent: Codable {
    case text(String)
    case array([AnthropicContentItem])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let items = try? container.decode([AnthropicContentItem].self) {
            self = .array(items)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid content type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .text(let text):
            try container.encode(text)
        case .array(let items):
            try container.encode(items)
        }
    }
}

public struct AnthropicContentItem: Codable {
    public let type: String
    public let text: String?
    public let source: AnthropicImageSource?
    
    public init(type: String, text: String? = nil, source: AnthropicImageSource? = nil) {
        self.type = type
        self.text = text
        self.source = source
    }
}

public struct AnthropicImageSource: Codable {
    public let type: String
    public let media_type: String
    public let data: String
    
    public init(type: String, mediaType: String, data: String) {
        self.type = type
        self.media_type = mediaType
        self.data = data
    }
}

public struct AnthropicRequestBody: Codable {
    public let model: String
    public let messages: [AnthropicMessage]
    public let max_tokens: Int
    public let temperature: Double?
    public let top_p: Double?
    public let top_k: Int?
    public let stream: Bool
    
    public init(
        model: String,
        messages: [AnthropicMessage],
        maxTokens: Int = 4096,
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        stream: Bool = false
    ) {
        self.model = model
        self.messages = messages
        self.max_tokens = maxTokens
        self.temperature = temperature
        self.top_p = topP
        self.top_k = topK
        self.stream = stream
    }
}

// MARK: - Anthropic Response Structures

public struct AnthropicResponse: Codable {
    public let id: String
    public let type: String
    public let role: String
    public let content: [AnthropicContentItem]
    public let stop_reason: String?
    public let model: String
}

public struct AnthropicErrorResponse: Codable {
    public let type: String
    public let error: AnthropicErrorDetail
}

public struct AnthropicErrorDetail: Codable {
    public let type: String
    public let message: String
}

public enum AnthropicCustomError: Error, LocalizedError {
    case custom(message: String, statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .custom(let message, _):
            return message
        }
    }
}
