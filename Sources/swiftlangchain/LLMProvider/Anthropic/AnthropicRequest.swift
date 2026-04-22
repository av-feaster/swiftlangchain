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
    public let tools: [AnthropicTool]?
    
    public init(
        model: String,
        messages: [AnthropicMessage],
        maxTokens: Int = 4096,
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        stream: Bool = false,
        tools: [AnthropicTool]? = nil
    ) {
        self.model = model
        self.messages = messages
        self.max_tokens = maxTokens
        self.temperature = temperature
        self.top_p = topP
        self.top_k = topK
        self.stream = stream
        self.tools = tools
    }
}

// MARK: - Anthropic Tool Calling Structures

/// Anthropic tool definition
public struct AnthropicTool: Codable {
    public let name: String
    public let description: String
    public let input_schema: AnthropicToolInputSchema
    
    enum CodingKeys: String, CodingKey {
        case name, description
        case input_schema
    }
}

/// Anthropic tool input schema
public struct AnthropicToolInputSchema: Codable {
    public let type: String
    public let properties: [String: AnthropicPropertyDefinition]?
    public let required: [String]?
    
    public init(type: String = "object", properties: [String: AnthropicPropertyDefinition]? = nil, required: [String]? = nil) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

/// Anthropic property definition
public struct AnthropicPropertyDefinition: Codable {
    public let type: String
    public let description: String?
    
    public init(type: String, description: String? = nil) {
        self.type = type
        self.description = description
    }
}

/// Anthropic tool use content item
public struct AnthropicToolUseContentItem: Codable {
    public let type: String
    public let id: String
    public let name: String
    public let input: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case type, id, name, input
    }
    
    public init(type: String, id: String, name: String, input: [String: String]? = nil) {
        self.type = type
        self.id = id
        self.name = name
        self.input = input
    }
}

/// Anthropic tool result content item
public struct AnthropicToolResultContentItem: Codable {
    public let type: String
    public let tool_use_id: String
    public let content: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case tool_use_id
        case content
    }
    
    public init(type: String, toolUseId: String, content: String) {
        self.type = type
        self.tool_use_id = toolUseId
        self.content = content
    }
}

// MARK: - Anthropic Models API

/// Anthropic Models Response
public struct AnthropicModelsResponse: Codable {
    public let data: [AnthropicModel]
}

/// Anthropic Model
public struct AnthropicModel: Codable {
    public let id: String
    public let name: String
    public let displayName: String?
    public let type: String?
    public let contextLength: Int?
    public let maxTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type
        case displayName = "display_name"
        case contextLength = "context_length"
        case maxTokens = "max_tokens"
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
