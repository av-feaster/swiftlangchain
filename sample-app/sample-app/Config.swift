//
//  Config.swift
//  sample-app
//
//  Configuration manager for environment variables and API keys
//

import Foundation

/// Configuration manager for the app
public struct Config {
    
    // MARK: - OpenAI Configuration
    
    /// OpenAI API Key - loaded from environment or Info.plist
    public static var openAIAPIKey: String {
        // Try environment variable first (for Xcode schemes)
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        // Try bundle (Info.plist)
        if let bundleKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !bundleKey.isEmpty {
            return bundleKey
        }
        
        // Fallback to build configuration
        if let buildKey = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String, !buildKey.isEmpty {
            return buildKey
        }
        
        return ""
    }
    
    /// OpenAI Model name
    public static var openAIModel: String {
        if let envModel = ProcessInfo.processInfo.environment["OPENAI_MODEL"], !envModel.isEmpty {
            return envModel
        }
        
        if let bundleModel = Bundle.main.object(forInfoDictionaryKey: "OPENAI_MODEL") as? String, !bundleModel.isEmpty {
            return bundleModel
        }
        
        return "gpt-3.5-turbo"
    }
    
    // MARK: - Anthropic/Claude Configuration
    
    /// Anthropic API Key
    public static var claudeAPIKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["CLAUDE_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        if let bundleKey = Bundle.main.object(forInfoDictionaryKey: "CLAUDE_API_KEY") as? String, !bundleKey.isEmpty {
            return bundleKey
        }
        
        return nil
    }
    
    /// Anthropic Model name
    public static var claudeModel: String? {
        if let envModel = ProcessInfo.processInfo.environment["CLAUDE_MODEL"], !envModel.isEmpty {
            return envModel
        }
        
        if let bundleModel = Bundle.main.object(forInfoDictionaryKey: "CLAUDE_MODEL") as? String, !bundleModel.isEmpty {
            return bundleModel
        }
        
        return "claude-3-5-sonnet-20241022"
    }
    
    // MARK: - Google Gemini Configuration
    
    /// Gemini API Key
    public static var geminiAPIKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        if let bundleKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String, !bundleKey.isEmpty {
            return bundleKey
        }
        
        return nil
    }
    
    /// Gemini Model name
    public static var geminiModel: String? {
        if let envModel = ProcessInfo.processInfo.environment["GEMINI_MODEL"], !envModel.isEmpty {
            return envModel
        }
        
        if let bundleModel = Bundle.main.object(forInfoDictionaryKey: "GEMINI_MODEL") as? String, !bundleModel.isEmpty {
            return bundleModel
        }
        
        return "gemini-1.5-pro"
    }
    
    // MARK: - Cohere Configuration
    
    /// Cohere API Key
    public static var cohereAPIKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["COHERE_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        
        if let bundleKey = Bundle.main.object(forInfoDictionaryKey: "COHERE_API_KEY") as? String, !bundleKey.isEmpty {
            return bundleKey
        }
        
        return nil
    }
    
    /// Cohere Model name
    public static var cohereModel: String? {
        if let envModel = ProcessInfo.processInfo.environment["COHERE_MODEL"], !envModel.isEmpty {
            return envModel
        }
        
        if let bundleModel = Bundle.main.object(forInfoDictionaryKey: "COHERE_MODEL") as? String, !bundleModel.isEmpty {
            return bundleModel
        }
        
        return "command-r-plus"
    }
    
    // MARK: - Memory Configuration
    
    /// Maximum tokens for context memory
    public static var maxTokens: Int {
        if let envTokens = ProcessInfo.processInfo.environment["MAX_TOKENS"],
           let tokens = Int(envTokens) {
            return tokens
        }
        
        if let bundleTokens = Bundle.main.object(forInfoDictionaryKey: "MAX_TOKENS") as? Int {
            return bundleTokens
        }
        
        return 4000
    }
    
    /// Maximum messages in memory
    public static var maxMessages: Int {
        if let envMessages = ProcessInfo.processInfo.environment["MAX_MESSAGES"],
           let messages = Int(envMessages) {
            return messages
        }
        
        if let bundleMessages = Bundle.main.object(forInfoDictionaryKey: "MAX_MESSAGES") as? Int {
            return bundleMessages
        }
        
        return 10
    }
    
    // MARK: - Validation
    
    /// Check if API key is configured
    public static var isAPIKeyConfigured: Bool {
        !openAIAPIKey.isEmpty && openAIAPIKey != "your-api-key-here"
    }
    
    /// Validate configuration
    public static func validate() -> String? {
        if !isAPIKeyConfigured {
            return "OpenAI API key is not configured. Please set OPENAI_API_KEY in your Xcode scheme or Info.plist"
        }
        return nil
    }
}
