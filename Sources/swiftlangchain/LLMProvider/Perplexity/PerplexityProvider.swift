//
//  PerplexityProvider.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Perplexity API provider implementation (search-focused LLM)
public struct PerplexityProvider: LLMProvider, ModelFetcher {
    let apiKey: String
    let baseURL: String
    let model: String
    let maxTokens: Int
    
    public init(
        apiKey: String,
        model: String = "sonar-online",
        baseURL: String = "https://api.perplexity.ai",
        maxTokens: Int = 4096
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
        self.maxTokens = maxTokens
    }
    
    /// Fetch available models from Perplexity API
    public func fetchModels() async throws -> [ModelInfo] {
        // Check cache first
        if let cached = await sharedModelCache.get(key: "perplexity") {
            return cached
        }
        
        guard let url = URL(string: "\(baseURL)/models") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(httpResponse.statusCode, data)
        }
        
        let modelsResponse = try JSONDecoder().decode(PerplexityModelsResponse.self, from: data)
        
        let modelInfos = modelsResponse.models.map { model in
            ModelInfo(
                id: model.name,
                name: model.displayName ?? model.name,
                description: model.type,
                contextLength: model.contextLength,
                maxTokens: nil
            )
        }
        
        // Cache the results
        await sharedModelCache.set(key: "perplexity", models: modelInfos)
        
        return modelInfos
    }
    
    public func generate(prompt: String) async throws -> String {
        return try await generate(prompt: prompt, parameters: GenerationParameters())
    }
    
    public func generate(prompt: String, parameters: GenerationParameters) async throws -> String {
        let message = PerplexityMessage(role: "user", content: prompt)
        return try await generateWithMessages([message], parameters: parameters)
    }
    
    /// Generate response with messages
    public func generateWithMessages(_ messages: [PerplexityMessage], parameters: GenerationParameters = GenerationParameters()) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw NetworkError.invalidURL
        }
        
        let request = PerplexityRequest(
            model: model,
            messages: messages,
            stream: false,
            maxTokens: parameters.maxTokens ?? maxTokens,
            temperature: parameters.temperature
        )
        
        let headers = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorResponse = try? JSONDecoder().decode(PerplexityErrorResponse.self, from: data) {
                throw NetworkError.requestFailed(NSError(domain: "Perplexity", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message]))
            }
            throw NetworkError.httpError(httpResponse.statusCode, data)
        }
        
        let perplexityResponse = try JSONDecoder().decode(PerplexityResponse.self, from: data)
        
        guard let choice = perplexityResponse.choices.first else {
            throw NetworkError.invalidResponse
        }
        
        return choice.message.content
    }
}
