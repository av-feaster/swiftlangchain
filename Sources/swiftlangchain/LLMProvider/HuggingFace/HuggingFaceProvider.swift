//
//  HuggingFaceProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Hugging Face Inference API provider implementation
public struct HuggingFaceProvider: LLMProvider {
    let apiKey: String
    let baseURL: String
    let model: String
    
    public init(
        apiKey: String,
        model: String = "meta-llama/Llama-2-7b-chat-hf",
        baseURL: String = "https://api-inference.huggingface.co/models"
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
    }
    
    public func generate(prompt: String) async throws -> String {
        return try await generate(prompt: prompt, parameters: GenerationParameters())
    }
    
    public func generate(prompt: String, parameters: GenerationParameters) async throws -> String {
        // Construct the API URL
        guard let url = URL(string: "\(baseURL)/\(model)") else {
            throw NetworkError.invalidURL
        }
        
        // Prepare headers
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        // Create generation parameters
        let hfParams = HuggingFaceParameters(
            maxNewTokens: parameters.maxTokens,
            temperature: parameters.temperature,
            topP: parameters.topP,
            topK: nil,
            repetitionPenalty: parameters.frequencyPenalty
        )
        
        // Create the request body
        let requestBody = HuggingFaceRequestBody(
            inputs: prompt,
            parameters: hfParams,
            model: nil
        )
        
        do {
            // Make the API call using NetworkClient
            let response: HuggingFaceResponse = try await NetworkClient.postUnsafe(
                url: url,
                headers: headers,
                body: try JSONEncoder().encode(requestBody).toDictionary(),
                responseType: HuggingFaceResponse.self
            )
            
            // Check for error
            if let error = response.error {
                throw NetworkError.requestFailed(NSError(domain: "HuggingFace", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
            }
            
            guard let generatedText = response.generated_text else {
                throw NetworkError.invalidResponse
            }
            
            // Remove the input prompt from the response (Hugging Face returns input + output)
            if generatedText.hasPrefix(prompt) {
                return String(generatedText.dropFirst(prompt.count))
            }
            
            return generatedText
            
        } catch let networkError as NetworkError {
            // Handle network-specific errors
            switch networkError {
            case .httpError(let statusCode, let data):
                // Try to parse error response
                if let errorResponse = try? JSONDecoder().decode(HuggingFaceResponse.self, from: data),
                   let error = errorResponse.error {
                    throw HuggingFaceCustomError.custom(message: error, statusCode: statusCode)
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
    
    /// Generate response with ChatMessages
    public func generateWithMessages(_ messages: [ChatMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        // Convert ChatMessages to a single prompt string
        let prompt = messages.map { message in
            "\(message.role.rawValue): \(message.textContent ?? "")"
        }.joined(separator: "\n")
        
        return try await generate(prompt: prompt, parameters: parameters)
    }
}
