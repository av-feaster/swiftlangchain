import Foundation

/// Protocol for tools that can be used by agents
public protocol Tool: Sendable {
    var name: String { get }
    var description: String { get }
    
    /// Execute the tool with the given input
    func execute(_ input: String) async throws -> String
    
    /// Synchronous execution (required for chaining or default async behavior)
    func syncExecute(_ input: String) throws -> String
}

// MARK: - Protocol Extensions for Common Functionality

/// Extension providing default implementations and additional functionality
public extension Tool {
    /// Default implementation for tools that don't need async execution
    func execute(_ input: String) async throws -> String {
        if #available(macOS 10.15, *) {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global().async {
                    do {
                        let result = try self.syncExecute(input)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        } else {
            throw ToolError.executionFailed("Unsupported OS version")
        }

        
    }
    
    

    
    /// Validate input before execution
    func validateInput(_ input: String) -> Bool {
        return !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get tool metadata for agent planning
    var metadata: [String: Any] {
        return [
            "name": name,
            "description": description,
            "type": "tool"
        ]
    }
}

// MARK: - Tool Categories

/// Protocol for tools that can be chained together
public protocol ChainableTool: Tool {
    /// Execute this tool and pass the result to the next tool
    func chain<T: Tool>(with next: T) -> ChainedTool<Self, T>
}

/// Protocol for tools that require authentication
public protocol AuthenticatedTool: Tool {
    var isAuthenticated: Bool { get }
    mutating func authenticate() async throws
}

/// Protocol for tools that can be rate limited
public protocol RateLimitedTool: Tool {
    var rateLimit: TimeInterval { get }
    var lastExecutionTime: Date? { get set }
}


// MARK: - Tool Composition

/// A tool that chains two other tools together
public struct ChainedTool<T1: Tool, T2: Tool>: Tool {
    public let name: String
    public let description: String
    
    private let first: T1
    private let second: T2
    
    public init(first: T1, second: T2) {
        self.first = first
        self.second = second
        self.name = "chained_\(first.name)_\(second.name)"
        self.description = "Chains \(first.name) and \(second.name) together"
    }
    
    public func syncExecute(_ input: String) throws -> String {
            let firstResult = try first.syncExecute(input)
            return try second.syncExecute(firstResult)
    }
}

// MARK: - Tool Errors

public enum ToolError: Error, LocalizedError {
    case notAuthenticated
    case rateLimitExceeded
    case invalidInput
    case executionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Tool requires authentication"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case .invalidInput:
            return "Invalid input provided"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        }
    }
}


public actor ToolRegistry {
    private var tools: [String: any Tool] = [:]
    
    public static let shared = ToolRegistry()
    
    private init() {}
    
    public func register<T: Tool>(_ tool: T) {
        tools[tool.name] = tool
    }
    
    public func getTool(named name: String) -> (any Tool)? {
        return tools[name]
    }
    
    public func getAllTools() -> [any Tool] {
        return Array(tools.values)
    }
    
    public func clear() {
        tools.removeAll()
    }
}

