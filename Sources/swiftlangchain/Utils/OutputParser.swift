//
//  OutputParser.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


import Foundation

/// Protocol for parsing LLM outputs into structured data
public protocol OutputParser {
    associatedtype Output
    
    /// Parse the LLM output into structured data
    func parse(_ text: String) throws -> Output
}

/// Parser for JSON outputs
public struct JSONOutputParser<T: Codable>: OutputParser {
    public typealias Output = T
    
    public init() {}
    
    public func parse(_ text: String) throws -> T {
        guard let data = text.data(using: .utf8) else {
            throw ParserError.invalidData
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

/// Parser for simple text outputs
public struct TextOutputParser: OutputParser {
    public typealias Output = String
    
    public init() {}
    
    public func parse(_ text: String) throws -> String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Parser errors
public enum ParserError: Error {
    case invalidData
    case parsingFailed
}