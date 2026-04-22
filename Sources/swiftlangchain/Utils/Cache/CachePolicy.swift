//
//  CachePolicy.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Cache policy configuration
public struct CachePolicy {
    public let maxAge: TimeInterval
    public let maxSize: Int
    public let evictionPolicy: EvictionPolicy
    
    public init(maxAge: TimeInterval = 3600, maxSize: Int = 100, evictionPolicy: EvictionPolicy = .lru) {
        self.maxAge = maxAge
        self.maxSize = maxSize
        self.evictionPolicy = evictionPolicy
    }
    
    /// Eviction policy for cache
    public enum EvictionPolicy {
        case lru  // Least Recently Used
        case fifo // First In First Out
        case lfu  // Least Frequently Used
    }
}

/// Cache entry metadata
public struct CacheEntry {
    public let key: String
    public let value: String
    public let timestamp: Date
    public let accessCount: Int
    public let lastAccessed: Date
    
    public init(key: String, value: String, timestamp: Date = Date(), accessCount: Int = 1, lastAccessed: Date = Date()) {
        self.key = key
        self.value = value
        self.timestamp = timestamp
        self.accessCount = accessCount
        self.lastAccessed = lastAccessed
    }
    
    /// Check if the entry has expired based on the policy
    func isExpired(policy: CachePolicy) -> Bool {
        return Date().timeIntervalSince(timestamp) > policy.maxAge
    }
}

/// Cache statistics
public struct CacheStatistics {
    public let hitCount: Int
    public let missCount: Int
    public let size: Int
    public let totalEntries: Int
    
    public var hitRate: Double {
        let total = hitCount + missCount
        return total > 0 ? Double(hitCount) / Double(total) : 0.0
    }
    
    public init(hitCount: Int = 0, missCount: Int = 0, size: Int = 0, totalEntries: Int = 0) {
        self.hitCount = hitCount
        self.missCount = missCount
        self.size = size
        self.totalEntries = totalEntries
    }
}
