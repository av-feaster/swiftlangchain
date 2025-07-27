// The Swift Programming Language
// https://docs.swift.org/swift-book

// SwiftLangChain.swift
// Main entry point for the SwiftLangChain framework

@_exported import Foundation

// MARK: - Core Framework Components

// Re-export main components for easy access
public struct SwiftLangChain {
    public init() {}
}

// Version information
public extension SwiftLangChain {
    static let version = "0.1.0"
}

// MARK: - Module Re-exports

// This file serves as the main entry point and re-exports all public APIs
// All other files in the module are automatically available when importing SwiftLangChain