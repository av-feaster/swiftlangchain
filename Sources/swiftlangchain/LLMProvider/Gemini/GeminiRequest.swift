//
//  GeminiRequest.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Gemini Request Structures

public struct GeminiMessage: Codable {
    public let role: String
    public let parts: [GeminiPart]
    
    public init(role: String, parts: [GeminiPart]) {
        self.role = role
        self.parts = parts
    }
}

public struct GeminiPart: Codable {
    public let text: String?
    public let inline_data: GeminiInlineData?
    
    public init(text: String? = nil, inlineData: GeminiInlineData? = nil) {
        self.text = text
        self.inline_data = inlineData
    }
}

public struct GeminiInlineData: Codable {
    public let mime_type: String
    public let data: String
    
    public init(mimeType: String, data: String) {
        self.mime_type = mimeType
        self.data = data
    }
}

public struct GeminiRequestBody: Codable {
    public let contents: [GeminiMessage]
    public let generationConfig: GeminiGenerationConfig?
    public let safetySettings: [GeminiSafetySetting]?
    
    public init(
        contents: [GeminiMessage],
        generationConfig: GeminiGenerationConfig? = nil,
        safetySettings: [GeminiSafetySetting]? = nil
    ) {
        self.contents = contents
        self.generationConfig = generationConfig
        self.safetySettings = safetySettings
    }
}

public struct GeminiGenerationConfig: Codable {
    public let temperature: Double?
    public let topP: Double?
    public let topK: Int?
    public let maxOutputTokens: Int?
    
    public init(
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        maxOutputTokens: Int? = nil
    ) {
        self.temperature = temperature
        self.topP = topP
        self.topK = topK
        self.maxOutputTokens = maxOutputTokens
    }
}

public struct GeminiSafetySetting: Codable {
    public let category: String
    public let threshold: String
    
    public init(category: String, threshold: String = "BLOCK_MEDIUM_AND_ABOVE") {
        self.category = category
        self.threshold = threshold
    }
}

// MARK: - Gemini Response Structures

public struct GeminiResponse: Codable {
    public let candidates: [GeminiCandidate]
}

public struct GeminiCandidate: Codable {
    public let content: GeminiMessageContent
    public let finishReason: String?
    public let index: Int
}

public struct GeminiMessageContent: Codable {
    public let parts: [GeminiPart]
    public let role: String
}

public struct GeminiErrorResponse: Codable {
    public let error: GeminiErrorDetail
}

public struct GeminiErrorDetail: Codable {
    public let code: Int
    public let message: String
    public let status: String
}

public enum GeminiCustomError: Error, LocalizedError {
    case custom(message: String, statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .custom(let message, _):
            return message
        }
    }
}
