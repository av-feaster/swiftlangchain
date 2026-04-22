//
//  HuggingFaceRequest.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Hugging Face Request Structures

public struct HuggingFaceRequestBody: Codable {
    public let inputs: String
    public let parameters: HuggingFaceParameters?
    public let model: String?
    
    public init(
        inputs: String,
        parameters: HuggingFaceParameters? = nil,
        model: String? = nil
    ) {
        self.inputs = inputs
        self.parameters = parameters
        self.model = model
    }
}

public struct HuggingFaceParameters: Codable {
    public let max_new_tokens: Int?
    public let temperature: Double?
    public let top_p: Double?
    public let top_k: Int?
    public let repetition_penalty: Double?
    
    public init(
        maxNewTokens: Int? = nil,
        temperature: Double? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        repetitionPenalty: Double? = nil
    ) {
        self.max_new_tokens = maxNewTokens
        self.temperature = temperature
        self.top_p = topP
        self.top_k = topK
        self.repetition_penalty = repetitionPenalty
    }
}

// MARK: - Hugging Face Response Structures

public struct HuggingFaceResponse: Codable {
    public let generated_text: String?
    public let error: String?
}

public struct HuggingFaceStreamResponse: Codable {
    public let token: HuggingFaceToken?
    public let generated_text: String?
    public let error: String?
}

public struct HuggingFaceToken: Codable {
    public let id: Int
    public let text: String
    public let logprob: Double?
    public let special: Bool
}

public enum HuggingFaceCustomError: Error, LocalizedError {
    case custom(message: String, statusCode: Int)
    
    public var errorDescription: String? {
        switch self {
        case .custom(let message, _):
            return message
        }
    }
}
