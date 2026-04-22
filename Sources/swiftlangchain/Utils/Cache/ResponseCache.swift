//
//  ResponseCache.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Cache for LLM responses
public actor ResponseCache {
    private var cache: [String: CacheEntry] = [:]
    private var policy: CachePolicy
    private var statistics: CacheStatistics
    
    public init(policy: CachePolicy = CachePolicy()) {
        self.policy = policy
        self.statistics = CacheStatistics()
    }
    
    /// Generate a cache key from a prompt and parameters
    public func generateKey(prompt: String, parameters: GenerationParameters? = nil) -> String {
        var key = prompt
        
        if let params = parameters {
            key += "_\(params.temperature)_\(params.maxTokens ?? 0)"
        }
        
        return key
    }
    
    /// Get a cached response
    public func get(key: String) -> String? {
        guard let entry = cache[key] else {
            statistics = CacheStatistics(
                hitCount: statistics.hitCount,
                missCount: statistics.missCount + 1,
                size: statistics.size,
                totalEntries: cache.count
            )
            return nil
        }
        
        // Check if entry has expired
        if entry.isExpired(policy: policy) {
            cache.removeValue(forKey: key)
            statistics = CacheStatistics(
                hitCount: statistics.hitCount,
                missCount: statistics.missCount + 1,
                size: statistics.size,
                totalEntries: cache.count
            )
            return nil
        }
        
        // Update access count and last accessed time
        var updatedEntry = entry
        updatedEntry = CacheEntry(
            key: entry.key,
            value: entry.value,
            timestamp: entry.timestamp,
            accessCount: entry.accessCount + 1,
            lastAccessed: Date()
        )
        cache[key] = updatedEntry
        
        statistics = CacheStatistics(
            hitCount: statistics.hitCount + 1,
            missCount: statistics.missCount,
            size: statistics.size,
            totalEntries: cache.count
        )
        
        return entry.value
    }
    
    /// Set a cached response
    public func set(key: String, value: String) {
        // Check if we need to evict entries
        if cache.count >= policy.maxSize {
            evict()
        }
        
        let entry = CacheEntry(key: key, value: value)
        cache[key] = entry
        
        statistics = CacheStatistics(
            hitCount: statistics.hitCount,
            missCount: statistics.missCount,
            size: statistics.size,
            totalEntries: cache.count
        )
    }
    
    /// Remove a cached response
    public func remove(key: String) {
        cache.removeValue(forKey: key)
        
        statistics = CacheStatistics(
            hitCount: statistics.hitCount,
            missCount: statistics.missCount,
            size: statistics.size,
            totalEntries: cache.count
        )
    }
    
    /// Clear all cached responses
    public func clear() {
        cache.removeAll()
        
        statistics = CacheStatistics(
            hitCount: statistics.hitCount,
            missCount: statistics.missCount,
            size: 0,
            totalEntries: 0
        )
    }
    
    /// Get cache statistics
    public func getStatistics() -> CacheStatistics {
        return statistics
    }
    
    /// Evict entries based on policy
    private func evict() {
        switch policy.evictionPolicy {
        case .lru:
            evictLRU()
        case .fifo:
            evictFIFO()
        case .lfu:
            evictLFU()
        }
    }
    
    private func evictLRU() {
        // Remove least recently used entry
        let oldestKey = cache.min { $0.value.lastAccessed < $1.value.lastAccessed }?.key
        if let key = oldestKey {
            cache.removeValue(forKey: key)
        }
    }
    
    private func evictFIFO() {
        // Remove oldest entry by timestamp
        let oldestKey = cache.min { $0.value.timestamp < $1.value.timestamp }?.key
        if let key = oldestKey {
            cache.removeValue(forKey: key)
        }
    }
    
    private func evictLFU() {
        // Remove least frequently used entry
        let leastAccessedKey = cache.min { $0.value.accessCount < $1.value.accessCount }?.key
        if let key = leastAccessedKey {
            cache.removeValue(forKey: key)
        }
    }
}

/// Persistent cache using UserDefaults
public actor PersistentCache {
    private let userDefaults: UserDefaults
    private let keyPrefix: String
    
    public init(userDefaults: UserDefaults = .standard, keyPrefix: String = "swiftlangchain_cache_") {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
    }
    
    /// Get a cached response from persistent storage
    public func get(key: String) -> String? {
        let fullKey = keyPrefix + key
        return userDefaults.string(forKey: fullKey)
    }
    
    /// Set a cached response in persistent storage
    public func set(key: String, value: String) {
        let fullKey = keyPrefix + key
        userDefaults.set(value, forKey: fullKey)
    }
    
    /// Remove a cached response from persistent storage
    public func remove(key: String) {
        let fullKey = keyPrefix + key
        userDefaults.removeObject(forKey: fullKey)
    }
    
    /// Clear all cached responses from persistent storage
    public func clear() {
        let keys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(keyPrefix) }
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
}
