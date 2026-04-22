//
//  FunctionTool.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - Function Tool Protocol

/// Protocol for tools that can be used with OpenAI function calling
public protocol FunctionTool: Tool {
    /// Function definition for OpenAI function calling
    var functionDefinition: OpenAIFunction { get }
    
    /// Execute the tool with parsed arguments
    func executeWithArguments(_ arguments: [String: Any]) async throws -> String
}

// MARK: - Default Implementation

public extension FunctionTool {
    /// Default implementation that converts arguments to JSON string
    func execute(_ input: String) async throws -> String {
        // Parse input as JSON arguments
        guard let data = input.data(using: .utf8),
              let arguments = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ToolError.invalidInput
        }
        
        return try await executeWithArguments(arguments)
    }
    
    /// Default sync implementation
    func syncExecute(_ input: String) throws -> String {
        // For function tools, prefer async execution
        if #available(macOS 10.15, *) {
            let semaphore = DispatchSemaphore(value: 0)
            var result: String?
            var error: Error?
            
            Task {
                do {
                    result = try await execute(input)
                } catch let e {
                    error = e
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            
            if let error = error {
                throw error
            }
            
            return result ?? ""
        } else {
            throw ToolError.executionFailed("Async execution not supported on this OS version")
        }
    }
}

// MARK: - Function Tool Builder

/// Builder for creating function definitions
public struct FunctionDefinitionBuilder {
    private var name: String
    private var description: String
    private var properties: [String: OpenAIPropertyDefinition] = [:]
    private var required: [String] = []
    
    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    public func addProperty(_ name: String, type: String, description: String, isRequired: Bool = false) -> FunctionDefinitionBuilder {
        properties[name] = OpenAIPropertyDefinition(type: type, description: description)
        if isRequired {
            required.append(name)
        }
        return self
    }
    
    public func addEnumProperty(_ name: String, values: [String], description: String, isRequired: Bool = false) -> FunctionDefinitionBuilder {
        properties[name] = OpenAIPropertyDefinition(type: "string", description: description, enum_values: values)
        if isRequired {
            required.append(name)
        }
        return self
    }
    
    public func build() -> OpenAIFunction {
        return OpenAIFunction(
            name: name,
            description: description,
            parameters: OpenAIFunctionParameters(
                type: "object",
                properties: properties.isEmpty ? nil : properties,
                required: required.isEmpty ? nil : required
            )
        )
    }
}
