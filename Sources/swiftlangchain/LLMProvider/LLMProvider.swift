//
//  LLMProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


import Foundation

/// Protocol for LLM providers
public protocol LLMProvider {
    /// Generate a response for the given prompt
    func generate(prompt: String) async throws -> String
    
    /// Generate a response with additional parameters
    func generate(prompt: String, parameters: GenerationParameters) async throws -> String
}

/// Protocol for LLM providers that support streaming responses
public protocol StreamingLLMProvider: LLMProvider {
    /// Generate a streaming response for the given prompt
    func generateStream(prompt: String) async throws -> AsyncStream<StreamChunk>
    
    /// Generate a streaming response with additional parameters
    func generateStream(prompt: String, parameters: GenerationParameters) async throws -> AsyncStream<StreamChunk>
}

/// A chunk of streaming response
public struct StreamChunk {
    public let content: String
    public let isComplete: Bool
    
    public init(content: String, isComplete: Bool = false) {
        self.content = content
        self.isComplete = isComplete
    }
}

/// Parameters for text generation
public struct GenerationParameters {
    public let temperature: Double
    public let maxTokens: Int?
    public let topP: Double?
    public let frequencyPenalty: Double?
    public let presencePenalty: Double?
    
    public init(
        temperature: Double = 0.7,
        maxTokens: Int? = nil,
        topP: Double? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil
    ) {
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
    }
}