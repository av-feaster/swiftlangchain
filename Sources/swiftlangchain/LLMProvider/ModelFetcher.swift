//
//  ModelFetcher.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Model Fetching Protocol

/// Protocol for providers that can dynamically fetch available models
public protocol ModelFetcher {
    /// Fetch available models from the provider's API
    func fetchModels() async throws -> [ModelInfo]
}

/// Model information
public struct ModelInfo: Codable, Sendable {
    public let id: String
    public let name: String?
    public let description: String?
    public let contextLength: Int?
    public let maxTokens: Int?
    
    public init(id: String, name: String? = nil, description: String? = nil, contextLength: Int? = nil, maxTokens: Int? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.contextLength = contextLength
        self.maxTokens = maxTokens
    }
}

// MARK: - Model Cache

/// Cache for storing fetched models to avoid repeated API calls
public actor ModelCache {
    private var cache: [String: [ModelInfo]] = [:]
    private var timestamps: [String: Date] = [:]
    private let cacheDuration: TimeInterval
    
    public init(cacheDuration: TimeInterval = 3600) { // 1 hour default
        self.cacheDuration = cacheDuration
    }
    
    public func get(key: String) -> [ModelInfo]? {
        guard let timestamp = timestamps[key],
              Date().timeIntervalSince(timestamp) < cacheDuration else {
            return nil
        }
        return cache[key]
    }
    
    public func set(key: String, models: [ModelInfo]) {
        cache[key] = models
        timestamps[key] = Date()
    }
    
    public func clear() {
        cache.removeAll()
        timestamps.removeAll()
    }
}

/// Shared model cache instance
public let sharedModelCache = ModelCache()
