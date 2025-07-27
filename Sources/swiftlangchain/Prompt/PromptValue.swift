//
//  PromptValue.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Encapsulates a pre-filled prompt template
public struct PromptValue {
    public let text: String
    public let metadata: [String: Any]
    
    public init(text: String, metadata: [String: Any] = [:]) {
        self.text = text
        self.metadata = metadata
    }
    
    /// Create a PromptValue from a PromptTemplate
    public static func fromTemplate(_ template: PromptTemplate, variables: [String: String]) throws -> PromptValue {
        let formattedText = try template.format(variables)
        return PromptValue(text: formattedText)
    }
}
