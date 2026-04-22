//
//  CohereProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Cohere API provider implementation
public struct CohereProvider: LLMProvider {
    let apiKey: String
    let baseURL: String
    let model: String
    
    public init(
        apiKey: String,
        model: String = "command-r-plus",
        baseURL: String = "https://api.cohere.com/v1"
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
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw NetworkError.invalidURL
        }
        
        // Prepare headers
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        // Create the request body
        let requestBody = CohereRequestBody(
            message: prompt,
            chatHistory: nil,
            model: model,
            temperature: parameters.temperature,
            p: parameters.topP,
            k: nil,
            maxTokens: parameters.maxTokens
        )
        
        do {
            // Make the API call using NetworkClient
            let response: CohereResponse = try await NetworkClient.postUnsafe(
                url: url,
                headers: headers,
                body: try JSONEncoder().encode(requestBody).toDictionary(),
                responseType: CohereResponse.self
            )
            
            return response.text
            
        } catch let networkError as NetworkError {
            // Handle network-specific errors
            switch networkError {
            case .httpError(let statusCode, let data):
                // Try to parse Cohere error response
                if let errorResponse = try? JSONDecoder().decode(CohereErrorResponse.self, from: data) {
                    throw CohereCustomError.custom(message: errorResponse.message, statusCode: statusCode)
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
        // Convert ChatMessages to Cohere chat history
        let chatHistory = messages.dropLast().map { message in
            CohereMessage(role: message.role.rawValue, content: message.textContent ?? "")
        }
        
        // Get the last message as the current prompt
        guard let lastMessage = messages.last else {
            throw NetworkError.invalidResponse
        }
        
        let prompt = lastMessage.textContent ?? ""
        
        // Construct the API URL
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw NetworkError.invalidURL
        }
        
        // Prepare headers
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        // Create the request body
        let requestBody = CohereRequestBody(
            message: prompt,
            chatHistory: chatHistory.isEmpty ? nil : chatHistory,
            model: model,
            temperature: parameters.temperature,
            p: parameters.topP,
            k: nil,
            maxTokens: parameters.maxTokens
        )
        
        do {
            // Make the API call using NetworkClient
            let response: CohereResponse = try await NetworkClient.postUnsafe(
                url: url,
                headers: headers,
                body: try JSONEncoder().encode(requestBody).toDictionary(),
                responseType: CohereResponse.self
            )
            
            return response.text
            
        } catch let networkError as NetworkError {
            // Handle network-specific errors
            switch networkError {
            case .httpError(let statusCode, let data):
                // Try to parse Cohere error response
                if let errorResponse = try? JSONDecoder().decode(CohereErrorResponse.self, from: data) {
                    throw CohereCustomError.custom(message: errorResponse.message, statusCode: statusCode)
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
