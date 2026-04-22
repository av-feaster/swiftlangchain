//
//  RetryPolicy.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Retry policy configuration
public struct RetryPolicy {
    public let maxAttempts: Int
    public let backoffStrategy: BackoffStrategy
    public let initialDelay: TimeInterval
    public let maxDelay: TimeInterval
    public let jitter: Bool
    
    public init(
        maxAttempts: Int = 3,
        backoffStrategy: BackoffStrategy = .exponential,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 60.0,
        jitter: Bool = true
    ) {
        self.maxAttempts = maxAttempts
        self.backoffStrategy = backoffStrategy
        self.initialDelay = initialDelay
        self.maxDelay = maxDelay
        self.jitter = jitter
    }
    
    /// Calculate delay for a given attempt
    public func delayForAttempt(attempt: Int) -> TimeInterval {
        let baseDelay: TimeInterval
        
        switch backoffStrategy {
        case .fixed:
            baseDelay = initialDelay
        case .linear:
            baseDelay = initialDelay * Double(attempt)
        case .exponential:
            baseDelay = initialDelay * pow(2.0, Double(attempt - 1))
        }
        
        let delay = min(baseDelay, maxDelay)
        
        // Add jitter if enabled
        if jitter {
            let jitterAmount = delay * 0.1 // 10% jitter
            let randomJitter = Double.random(in: -jitterAmount...jitterAmount)
            return max(0, delay + randomJitter)
        }
        
        return delay
    }
    
    /// Backoff strategy
    public enum BackoffStrategy {
        case fixed
        case linear
        case exponential
    }
}

/// Retry statistics
public struct RetryStatistics {
    public let totalAttempts: Int
    public let successfulAttempts: Int
    public let failedAttempts: Int
    public let retryCount: Int
    
    public var successRate: Double {
        let total = totalAttempts
        return total > 0 ? Double(successfulAttempts) / Double(total) : 0.0
    }
    
    public init(totalAttempts: Int = 0, successfulAttempts: Int = 0, failedAttempts: Int = 0, retryCount: Int = 0) {
        self.totalAttempts = totalAttempts
        self.successfulAttempts = successfulAttempts
        self.failedAttempts = failedAttempts
        self.retryCount = retryCount
    }
}

/// Circuit breaker state
public enum CircuitBreakerState {
    case closed
    case open
    case halfOpen
}

/// Circuit breaker for preventing cascading failures
public actor CircuitBreaker {
    private var state: CircuitBreakerState = .closed
    private var failureCount: Int = 0
    private var lastFailureTime: Date?
    private let failureThreshold: Int
    private let timeout: TimeInterval
    private let resetTimeout: TimeInterval
    
    public init(failureThreshold: Int = 5, timeout: TimeInterval = 60.0, resetTimeout: TimeInterval = 30.0) {
        self.failureThreshold = failureThreshold
        self.timeout = timeout
        self.resetTimeout = resetTimeout
    }
    
    /// Check if the circuit breaker allows execution
    public func allowExecution() -> Bool {
        switch state {
        case .closed:
            return true
        case .open:
            if let lastFailure = lastFailureTime,
               Date().timeIntervalSince(lastFailure) > resetTimeout {
                state = .halfOpen
                return true
            }
            return false
        case .halfOpen:
            return true
        }
    }
    
    /// Record a successful execution
    public func recordSuccess() {
        failureCount = 0
        lastFailureTime = nil
        state = .closed
    }
    
    /// Record a failed execution
    public func recordFailure() {
        failureCount += 1
        lastFailureTime = Date()
        
        if failureCount >= failureThreshold {
            state = .open
        }
    }
    
    /// Get current circuit breaker state
    public func getState() -> CircuitBreakerState {
        return state
    }
}
