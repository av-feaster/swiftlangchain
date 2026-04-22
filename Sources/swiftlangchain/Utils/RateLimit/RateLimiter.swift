//
//  RateLimiter.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Rate limiter using token bucket algorithm
public actor RateLimiter {
    private var tokens: Double
    private let maxTokens: Double
    private let refillRate: Double // tokens per second
    private var lastRefillTime: Date
    
    public init(maxTokens: Double = 100, refillRate: Double = 10) {
        self.maxTokens = maxTokens
        self.refillRate = refillRate
        self.tokens = maxTokens
        self.lastRefillTime = Date()
    }
    
    /// Try to consume a token
    public func tryConsume() -> Bool {
        refill()
        
        if tokens >= 1 {
            tokens -= 1
            return true
        }
        
        return false
    }
    
    /// Try to consume multiple tokens
    public func tryConsume(count: Int) -> Bool {
        refill()
        
        if tokens >= Double(count) {
            tokens -= Double(count)
            return true
        }
        
        return false
    }
    
    /// Wait until a token is available
    public func waitForToken() async {
        while !tryConsume() {
            let waitTime = 1.0 / refillRate
            try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
    }
    
    /// Get current token count
    public func getCurrentTokens() -> Double {
        refill()
        return tokens
    }
    
    /// Reset the token bucket
    public func reset() {
        tokens = maxTokens
        lastRefillTime = Date()
    }
    
    /// Refill tokens based on elapsed time
    private func refill() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastRefillTime)
        let tokensToAdd = elapsed * refillRate
        
        tokens = min(maxTokens, tokens + tokensToAdd)
        lastRefillTime = now
    }
}

/// Sliding window rate limiter
public actor SlidingWindowRateLimiter {
    private var requests: [Date] = []
    private let windowSize: TimeInterval
    private let maxRequests: Int
    
    public init(windowSize: TimeInterval = 60, maxRequests: Int = 100) {
        self.windowSize = windowSize
        self.maxRequests = maxRequests
    }
    
    /// Check if a request is allowed
    public func allowRequest() -> Bool {
        let now = Date()
        let windowStart = now.addingTimeInterval(-windowSize)
        
        // Remove requests outside the window
        requests = requests.filter { $0 >= windowStart }
        
        // Check if we can make a request
        if requests.count < maxRequests {
            requests.append(now)
            return true
        }
        
        return false
    }
    
    /// Get current request count in the window
    public func getCurrentRequestCount() -> Int {
        let now = Date()
        let windowStart = now.addingTimeInterval(-windowSize)
        requests = requests.filter { $0 >= windowStart }
        return requests.count
    }
    
    /// Reset the rate limiter
    public func reset() {
        requests.removeAll()
    }
}

/// Rate limit status
public struct RateLimitStatus {
    public let remaining: Int
    public let resetTime: Date?
    public let limit: Int
    
    public init(remaining: Int, resetTime: Date? = nil, limit: Int) {
        self.remaining = remaining
        self.resetTime = resetTime
        self.limit = limit
    }
    
    /// Check if the rate limit has been exceeded
    public var isExceeded: Bool {
        return remaining <= 0
    }
}

/// Rate limit error
public enum RateLimitError: Error, LocalizedError {
    case exceeded(status: RateLimitStatus)
    
    public var errorDescription: String? {
        switch self {
        case .exceeded(let status):
            return "Rate limit exceeded. Remaining: \(status.remaining), Limit: \(status.limit)"
        }
    }
}
