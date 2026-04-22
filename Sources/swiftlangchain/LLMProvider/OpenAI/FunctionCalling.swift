//
//  FunctionCalling.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

// MARK: - OpenAI Function Calling Structures

/// OpenAI Function definition
public struct OpenAIFunction: Codable {
    public let name: String
    public let description: String
    public let parameters: OpenAIFunctionParameters?
    
    public init(name: String, description: String, parameters: OpenAIFunctionParameters? = nil) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

/// OpenAI Function parameters
public struct OpenAIFunctionParameters: Codable {
    public let type: String
    public let properties: [String: OpenAIPropertyDefinition]?
    public let required: [String]?
    
    public init(type: String = "object", properties: [String: OpenAIPropertyDefinition]? = nil, required: [String]? = nil) {
        self.type = type
        self.properties = properties
        self.required = required
    }
}

/// OpenAI Property definition
public struct OpenAIPropertyDefinition: Codable {
    public let type: String
    public let description: String?
    public let enum_values: [String]?
    
    public init(type: String, description: String? = nil, enum_values: [String]? = nil) {
        self.type = type
        self.description = description
        self.enum_values = enum_values
    }
    
    enum CodingKeys: String, CodingKey {
        case type, description
        case enum_values = "enum"
    }
}

/// OpenAI Tool definition
public struct OpenAITool: Codable {
    public let type: String
    public let function: OpenAIFunction
    
    public init(function: OpenAIFunction, type: String = "function") {
        self.type = type
        self.function = function
    }
}

/// OpenAI Function Call
public struct OpenAIFunctionCall: Codable {
    public let name: String
    public let arguments: String
    
    public init(name: String, arguments: String) {
        self.name = name
        self.arguments = arguments
    }
}

/// OpenAI Tool Call
public struct OpenAIToolCall: Codable {
    public let id: String
    public let type: String
    public let function: OpenAIFunctionCall
    
    public init(id: String, type: String = "function", function: OpenAIFunctionCall) {
        self.id = id
        self.type = type
        self.function = function
    }
}

