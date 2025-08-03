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
        // Convert text prompt to ChatMessage and then to OpenAIMessage
        let chatMessage = ChatMessage(role: .user, content: prompt)
        let openAIMessage = convertChatMessageToOpenAI(chatMessage)
        
        return try await generateWithMessages([openAIMessage], parameters: parameters)
    }
    
    /// Generate response with ChatMessages (supports images)
    public func generateWithMessages(_ messages: [ChatMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        let openAIMessages = messages.map { convertChatMessageToOpenAI($0) }
        return try await generateWithMessages(openAIMessages, parameters: parameters)
    }
    
    /// Generate response with OpenAIMessages
    public func generateWithMessages(_ messages: [OpenAIMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
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
            "messages": messages.map { message in
                var messageDict: [String: Any] = ["role": message.role]
                
                switch message.content {
                case .text(let text):
                    messageDict["content"] = text
                case .image(let imageUrl):
                    messageDict["content"] = [
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": imageUrl.url,
                                "detail": imageUrl.detail
                            ].compactMapValues { $0 }
                        ]
                    ]
                case .array(let items):
                    messageDict["content"] = items.map { item in
                        var itemDict: [String: Any] = ["type": item.type]
                        if let text = item.text {
                            itemDict["text"] = text
                        }
                        if let imageUrl = item.imageUrl {
                            itemDict["image_url"] = [
                                "url": imageUrl.url,
                                "detail": imageUrl.detail
                            ].compactMapValues { $0 }
                        }
                        return itemDict
                    }
                }
                
                return messageDict
            },
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
            
            // Extract text content from the response
            switch firstChoice.message.content {
            case .text(let text):
                return text
            case .image:
                throw NetworkError.invalidResponse // Assistant shouldn't return images
            case .array(let items):
                return items.compactMap { $0.text }.joined(separator: " ")
            }
            
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
    
    // MARK: - Helper Methods
    
    /// Convert ChatMessage to OpenAIMessage
    private func convertChatMessageToOpenAI(_ chatMessage: ChatMessage) -> OpenAIMessage {
        switch chatMessage.content {
        case .text(let text):
            return OpenAIMessage(role: chatMessage.role.rawValue, content: text)
        case .image(let imageContent):
            return OpenAIMessage(
                role: chatMessage.role.rawValue,
                imageUrl: imageContent.url,
                imageDetail: imageContent.detail
            )
        case .mixed(let items):
            let openAIItems = items.map { item in
                switch item.type {
                case "text":
                    return OpenAIContentItem(type: "text", text: item.text)
                case "image_url":
                    return OpenAIContentItem(
                        type: "image_url",
                        imageUrl: OpenAIImageUrl(
                            url: item.imageUrl?.url ?? "",
                            detail: item.imageUrl?.detail
                        )
                    )
                default:
                    return OpenAIContentItem(type: "text", text: item.text)
                }
            }
            return OpenAIMessage(role: chatMessage.role.rawValue, content: .array(openAIItems))
        }
    }
}

