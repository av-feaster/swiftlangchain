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

/// OpenAI Message Content Item
public struct OpenAIContentItem: Codable {
    public let type: String
    public let text: String?
    public let imageUrl: OpenAIImageUrl?
    
    public init(type: String, text: String? = nil, imageUrl: OpenAIImageUrl? = nil) {
        self.type = type
        self.text = text
        self.imageUrl = imageUrl
    }
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageUrl = "image_url"
    }
}

/// OpenAI Image URL
public struct OpenAIImageUrl: Codable {
    public let url: String?
    public let base64: String?
    public let detail: String?
    
    // Initialize with URL
    public init(url: String, detail: String? = nil) {
        self.url = url
        self.base64 = nil
        self.detail = detail
    }
    
    // Initialize with base64 data
    public init(base64: String, detail: String? = nil) {
        self.url = nil
        self.base64 = base64
        self.detail = detail
    }
    
    enum CodingKeys: String, CodingKey {
        case url, base64, detail
    }
}

/// OpenAI Message
public struct OpenAIMessage: Codable {
    public let role: String
    public let content: OpenAIMessageContent
    
    public init(role: String, content: OpenAIMessageContent) {
        self.role = role
        self.content = content
    }
    
    // Convenience initializer for text-only messages (backward compatibility)
    public init(role: String, content: String) {
        self.role = role
        self.content = .text(content)
    }
    
    // Convenience initializer for image-only messages (URL)
    public init(role: String, imageUrl: String, imageDetail: String? = nil) {
        self.role = role
        self.content = .image(OpenAIImageUrl(url: imageUrl, detail: imageDetail))
    }
    
    // Convenience initializer for image-only messages (base64)
    public init(role: String, imageBase64: String, imageDetail: String? = nil) {
        self.role = role
        self.content = .image(OpenAIImageUrl(base64: imageBase64, detail: imageDetail))
    }
    
    // Convenience initializer for mixed content (text + image URL)
    public init(role: String, text: String, imageUrl: String, imageDetail: String? = nil) {
        self.role = role
        let items: [OpenAIContentItem] = [
            OpenAIContentItem(type: "text", text: text),
            OpenAIContentItem(type: "image_url", imageUrl: OpenAIImageUrl(url: imageUrl, detail: imageDetail))
        ]
        self.content = .array(items)
    }
    
    // Convenience initializer for mixed content (text + base64 image)
    public init(role: String, text: String, imageBase64: String, imageDetail: String? = nil) {
        self.role = role
        let items: [OpenAIContentItem] = [
            OpenAIContentItem(type: "text", text: text),
            OpenAIContentItem(type: "image_url", imageUrl: OpenAIImageUrl(base64: imageBase64, detail: imageDetail))
        ]
        self.content = .array(items)
    }
}

/// OpenAI Message Content (can be string or array of content items)
public enum OpenAIMessageContent: Codable {
    case text(String)
    case image(OpenAIImageUrl)
    case array([OpenAIContentItem])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let stringValue = try? container.decode(String.self) {
            self = .text(stringValue)
        } else if let arrayValue = try? container.decode([OpenAIContentItem].self) {
            self = .array(arrayValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid content format")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .text(let string):
            try container.encode(string)
        case .image(let imageUrl):
            try container.encode([OpenAIContentItem(type: "image_url", imageUrl: imageUrl)])
        case .array(let items):
            try container.encode(items)
        }
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

/// Custom OpenAI Error
public enum OpenAICustomError: Error {
    case custom(message: String, statusCode: Int)
}
