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