//
//  GeminiProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Google Gemini API provider implementation
public struct GeminiProvider: LLMProvider {
    let apiKey: String
    let baseURL: String
    let model: String
    
    public init(
        apiKey: String,
        model: String = "gemini-1.5-pro",
        baseURL: String = "https://generativelanguage.googleapis.com/v1beta"
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
    }
    
    public func generate(prompt: String) async throws -> String {
        return try await generate(prompt: prompt, parameters: GenerationParameters())
    }
    
    public func generate(prompt: String, parameters: GenerationParameters) async throws -> String {
        // Convert text prompt to GeminiMessage
        let message = GeminiMessage(role: "user", parts: [GeminiPart(text: prompt)])
        
        return try await generateWithMessages([message], parameters: parameters)
    }
    
    /// Generate response with ChatMessages (supports images)
    public func generateWithMessages(_ messages: [ChatMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        let geminiMessages = messages.map { convertChatMessageToGemini($0) }
        return try await generateWithMessages(geminiMessages, parameters: parameters)
    }
    
    /// Generate response with GeminiMessages
    public func generateWithMessages(_ messages: [GeminiMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        // Construct the API URL
        guard let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        // Create generation config
        let generationConfig = GeminiGenerationConfig(
            temperature: parameters.temperature,
            topP: parameters.topP,
            topK: nil,
            maxOutputTokens: parameters.maxTokens
        )
        
        // Create the request body
        let requestBody = GeminiRequestBody(
            contents: messages,
            generationConfig: generationConfig,
            safetySettings: [
                GeminiSafetySetting(category: "HARM_CATEGORY_HARASSMENT"),
                GeminiSafetySetting(category: "HARM_CATEGORY_HATE_SPEECH"),
                GeminiSafetySetting(category: "HARM_CATEGORY_SEXUALLY_EXPLICIT"),
                GeminiSafetySetting(category: "HARM_CATEGORY_DANGEROUS_CONTENT")
            ]
        )
        
        do {
            // Make the API call using NetworkClient
            let response: GeminiResponse = try await NetworkClient.postUnsafe(
                url: url,
                headers: ["Content-Type": "application/json"],
                body: try JSONEncoder().encode(requestBody).toDictionary(),
                responseType: GeminiResponse.self
            )
            
            // Extract the response text
            guard let firstCandidate = response.candidates.first else {
                throw NetworkError.invalidResponse
            }
            
            guard let firstPart = firstCandidate.content.parts.first else {
                throw NetworkError.invalidResponse
            }
            
            guard let text = firstPart.text else {
                throw NetworkError.invalidResponse
            }
            
            return text
            
        } catch let networkError as NetworkError {
            // Handle network-specific errors
            switch networkError {
            case .httpError(let statusCode, let data):
                // Try to parse Gemini error response
                if let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) {
                    throw GeminiCustomError.custom(message: errorResponse.error.message, statusCode: statusCode)
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
    
    // MARK: - Helper Methods
    
    /// Convert ChatMessage to GeminiMessage
    private func convertChatMessageToGemini(_ chatMessage: ChatMessage) -> GeminiMessage {
        switch chatMessage.content {
        case .text(let text):
            return GeminiMessage(role: chatMessage.role.rawValue, parts: [GeminiPart(text: text)])
        case .image(let imageContent):
            // Convert image to base64 content item
            let inlineData: GeminiInlineData?
            if let base64 = imageContent.base64 {
                inlineData = GeminiInlineData(
                    mimeType: "image/jpeg",
                    data: base64
                )
            } else if let url = imageContent.url {
                // For URL-based images, we'd need to download and convert to base64
                // For now, we'll use a placeholder
                inlineData = nil
            } else {
                inlineData = nil
            }
            
            return GeminiMessage(role: chatMessage.role.rawValue, parts: [GeminiPart(inlineData: inlineData)])
        case .mixed(let items):
            let parts = items.map { item -> GeminiPart in
                if let text = item.text {
                    return GeminiPart(text: text)
                } else if let imageUrl = item.imageUrl {
                    let inlineData: GeminiInlineData?
                    if let base64 = imageUrl.base64 {
                        inlineData = GeminiInlineData(
                            mimeType: "image/jpeg",
                            data: base64
                        )
                    } else {
                        inlineData = nil
                    }
                    return GeminiPart(inlineData: inlineData)
                } else {
                    return GeminiPart(text: "")
                }
            }
            return GeminiMessage(role: chatMessage.role.rawValue, parts: parts)
        }
    }
}
