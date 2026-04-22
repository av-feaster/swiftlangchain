//
//  RetryableError.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

/// Protocol for errors that can be retried
public protocol RetryableError {
    var isRetryable: Bool { get }
    var retryAfter: TimeInterval? { get }
}

/// Extended NetworkError to support retry logic
extension NetworkError: RetryableError {
    public var isRetryable: Bool {
        switch self {
        case .invalidURL:
            return false
        case .requestFailed:
            return true
        case .invalidResponse:
            return true
        case .httpError(let statusCode, _):
            // Retry on 5xx errors and 429 (rate limit)
            return statusCode >= 500 || statusCode == 429
        case .decodingError:
            return false
        }
    }
    
    public var retryAfter: TimeInterval? {
        if case .httpError(let statusCode, _) = self, statusCode == 429 {
            // Rate limit error - wait 1 second before retry
            return 1.0
        }
        return nil
    }
}

/// Retry context for tracking retry attempts
public struct RetryContext {
    public let attempt: Int
    public let maxAttempts: Int
    public let lastError: Error?
    public let totalDelay: TimeInterval
    
    public init(attempt: Int, maxAttempts: Int, lastError: Error? = nil, totalDelay: TimeInterval = 0) {
        self.attempt = attempt
        self.maxAttempts = maxAttempts
        self.lastError = lastError
        self.totalDelay = totalDelay
    }
    
    /// Check if more retries are allowed
    public var shouldRetry: Bool {
        return attempt < maxAttempts
    }
    
    /// Check if this is the last attempt
    public var isLastAttempt: Bool {
        return attempt >= maxAttempts
    }
}
