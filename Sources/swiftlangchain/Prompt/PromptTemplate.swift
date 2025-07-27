//
//  PromptTemplate.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// A template for creating prompts with variable substitution
public struct PromptTemplate {
    public let template: String
    public let inputVariables: [String]
    
    public init(template: String, inputVariables: [String] = []) {
        self.template = template
        self.inputVariables = inputVariables
    }
    
    /// Format the template with the given variables
    public func format(_ variables: [String: String]) throws -> String {
        var result = template
        
        for (key, value) in variables {
            let placeholder = "{\(key)}"
            result = result.replacingOccurrences(of: placeholder, with: value)
        }
        
        return result
    }
    
    /// Format the template with the given variables
    public func format(_ variables: [String: Any]) throws -> String {
        let stringVariables = variables.mapValues { "\($0)" }
        return try format(stringVariables)
    }
}

