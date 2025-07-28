//
//  OpenAIProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// OpenAI API provider implementation
public struct OpenAIProvider: LLMProvider {
    let apiKey: String
    let baseURL: String
    let model: String
    
    public init(apiKey: String, model: String = "gpt-3.5-turbo", baseURL: String = "https://api.openai.com/v1") {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
    }
    
    public func generate(prompt: String) async throws -> String {
        return try await generate(prompt: prompt, parameters: GenerationParameters())
    }
    
    public func generate(prompt: String, parameters: GenerationParameters) async throws -> String {
        // Construct the API URL
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw NetworkError.invalidURL
        }
        
        // Prepare headers
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        // Create the request body
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": parameters.temperature,
            "max_tokens": parameters.maxTokens as Any,
            "top_p": parameters.topP as Any,
            "frequency_penalty": parameters.frequencyPenalty as Any,
            "presence_penalty": parameters.presencePenalty as Any
        ].compactMapValues { $0 } // Remove nil values
        
        do {
            // Make the API call using NetworkClient
            let response: OpenAIResponse = try await NetworkClient.postUnsafe(
                url: url,
                headers: headers,
                body: requestBody,
                responseType: OpenAIResponse.self
            )
            
            // Extract the response text
            guard let firstChoice = response.choices.first else {
                throw NetworkError.invalidResponse
            }
            
            return firstChoice.message.content
            
        } catch let networkError as NetworkError {
            // Handle network-specific errors
            switch networkError {
            case .httpError(let statusCode, let data):
                // Try to parse OpenAI error response
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    throw OpenAICustomError.custom(message: errorResponse.error.message, statusCode: statusCode)
                } else {
                    throw networkError
                }
            default:
                throw networkError
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    
    
}

