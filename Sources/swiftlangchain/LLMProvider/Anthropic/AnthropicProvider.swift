//
//  AnthropicProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Anthropic/Claude API provider implementation
public struct AnthropicProvider: LLMProvider {
    let apiKey: String
    let baseURL: String
    let model: String
    let maxTokens: Int
    
    public init(
        apiKey: String,
        model: String = "claude-3-5-sonnet-20241022",
        baseURL: String = "https://api.anthropic.com/v1",
        maxTokens: Int = 4096
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
        self.maxTokens = maxTokens
    }
    
    public func generate(prompt: String) async throws -> String {
        return try await generate(prompt: prompt, parameters: GenerationParameters())
    }
    
    public func generate(prompt: String, parameters: GenerationParameters) async throws -> String {
        // Convert text prompt to AnthropicMessage
        let message = AnthropicMessage(role: "user", content: .text(prompt))
        
        return try await generateWithMessages([message], parameters: parameters)
    }
    
    /// Generate response with ChatMessages (supports images)
    public func generateWithMessages(_ messages: [ChatMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        let anthropicMessages = messages.map { convertChatMessageToAnthropic($0) }
        return try await generateWithMessages(anthropicMessages, parameters: parameters)
    }
    
    /// Generate response with AnthropicMessages
    public func generateWithMessages(_ messages: [AnthropicMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        // Construct the API URL
        guard let url = URL(string: "\(baseURL)/messages") else {
            throw NetworkError.invalidURL
        }
        
        // Prepare headers
        let headers = [
            "x-api-key": apiKey,
            "anthropic-version": "2023-06-01",
            "Content-Type": "application/json"
        ]
        
        // Create the request body
        let requestBody = AnthropicRequestBody(
            model: model,
            messages: messages,
            maxTokens: maxTokens,
            temperature: parameters.temperature,
            topP: parameters.topP,
            topK: nil,
            stream: false
        )
        
        do {
            // Make the API call using NetworkClient
            let response: AnthropicResponse = try await NetworkClient.postUnsafe(
                url: url,
                headers: headers,
                body: try JSONEncoder().encode(requestBody).toDictionary(),
                responseType: AnthropicResponse.self
            )
            
            // Extract the response text
            guard let firstContent = response.content.first else {
                throw NetworkError.invalidResponse
            }
            
            guard let text = firstContent.text else {
                throw NetworkError.invalidResponse
            }
            
            return text
            
        } catch let networkError as NetworkError {
            // Handle network-specific errors
            switch networkError {
            case .httpError(let statusCode, let data):
                // Try to parse Anthropic error response
                if let errorResponse = try? JSONDecoder().decode(AnthropicErrorResponse.self, from: data) {
                    throw AnthropicCustomError.custom(message: errorResponse.error.message, statusCode: statusCode)
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
    
    /// Convert ChatMessage to AnthropicMessage
    private func convertChatMessageToAnthropic(_ chatMessage: ChatMessage) -> AnthropicMessage {
        switch chatMessage.content {
        case .text(let text):
            return AnthropicMessage(role: chatMessage.role.rawValue, content: .text(text))
        case .image(let imageContent):
            // Convert image to base64 content item
            let source: AnthropicImageSource?
            if let base64 = imageContent.base64 {
                source = AnthropicImageSource(
                    type: "base64",
                    mediaType: "image/jpeg",
                    data: base64
                )
            } else if let url = imageContent.url {
                // For URL-based images, we'd need to download and convert to base64
                // For now, we'll use a placeholder
                source = nil
            } else {
                source = nil
            }
            
            let contentItem = AnthropicContentItem(type: "image", source: source)
            return AnthropicMessage(role: chatMessage.role.rawValue, content: .array([contentItem]))
        case .mixed(let items):
            let contentItems = items.map { item in
                if let text = item.text {
                    return AnthropicContentItem(type: "text", text: text)
                } else if let imageUrl = item.imageUrl {
                    let source: AnthropicImageSource?
                    if let base64 = imageUrl.base64 {
                        source = AnthropicImageSource(
                            type: "base64",
                            mediaType: "image/jpeg",
                            data: base64
                        )
                    } else {
                        source = nil
                    }
                    return AnthropicContentItem(type: "image", source: source)
                } else {
                    return AnthropicContentItem(type: "text", text: "")
                }
            }
            return AnthropicMessage(role: chatMessage.role.rawValue, content: .array(contentItems))
        }
    }
}

// MARK: - Data Extension

extension Data {
    func toDictionary() -> [String: Any] {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] ?? [:]
        } catch {
            return [:]
        }
    }
}
