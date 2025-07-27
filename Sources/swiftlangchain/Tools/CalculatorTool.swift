//
//  CalculatorTool.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


import Foundation

public struct CalculatorTool: Tool {
    public let name = "calculator"
    public let description = "Performs mathematical calculations"

    public init() {}

    public func syncExecute(_ input: String) throws -> String {
        // Trim and validate input
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw ToolError.invalidInput
        }

        // Use NSExpression for basic math
        let expression = NSExpression(format: trimmed)
        if let result = expression.expressionValue(with: nil, context: nil) as? NSNumber {
            return result.stringValue
        } else {
            throw ToolError.executionFailed("Could not evaluate expression: \(input)")
        }
    }
}
