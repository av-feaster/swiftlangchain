//
//  CoreMLModelLoader.swift
//  swiftlangchain
//
//  Created by Aman Verma on 22/04/26.
//

import Foundation

#if canImport(CoreML)
@preconcurrency import CoreML

/// Error types for Core ML model loading
public enum CoreMLError: Error, LocalizedError {
    case modelNotFound
    case modelLoadFailed(Error)
    case deviceNotSupported
    case invalidModel
    case inferenceFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Core ML model not found"
        case .modelLoadFailed(let error):
            return "Failed to load Core ML model: \(error.localizedDescription)"
        case .deviceNotSupported:
            return "Device does not support Core ML"
        case .invalidModel:
            return "Invalid Core ML model"
        case .inferenceFailed(let error):
            return "Core ML inference failed: \(error.localizedDescription)"
        }
    }
}

/// Loader for Core ML models
public actor CoreMLModelLoader {
    private var loadedModels: [String: MLModel] = [:]
    
    public static let shared = CoreMLModelLoader()
    
    private init() {}
    
    /// Check if the device supports Core ML
    public func isCoreMLSupported() -> Bool {
        #if canImport(CoreML)
        return true // Core ML is available on iOS 11+ and macOS 10.13+
        #else
        return false
        #endif
    }
    
    /// Load a Core ML model from a URL
    public func loadModel(at url: URL, named name: String) async throws -> MLModel {
        #if canImport(CoreML)
        // Check if model is already loaded
        if let cachedModel = loadedModels[name] {
            return cachedModel
        }
        
        // Load the model
        let compiledModelURL = try MLModel.compileModel(at: url)
        let model = try MLModel(contentsOf: compiledModelURL)
        
        // Cache the model
        loadedModels[name] = model
        
        return model
        #else
        throw CoreMLError.deviceNotSupported
        #endif
    }
    
    /// Load a Core ML model by name from the main bundle
    public func loadModel(named name: String) async throws -> MLModel {
        #if canImport(CoreML)
        // Check if model is already loaded
        if let cachedModel = loadedModels[name] {
            return cachedModel
        }
        
        // Try to load from bundle
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "mlmodelc") else {
            throw CoreMLError.modelNotFound
        }
        
        return try await loadModel(at: modelURL, named: name)
        #else
        throw CoreMLError.deviceNotSupported
        #endif
    }
    
    /// Unload a model from memory
    public func unloadModel(named name: String) {
        loadedModels.removeValue(forKey: name)
    }
    
    /// Clear all loaded models
    public func clearAllModels() {
        loadedModels.removeAll()
    }
}

#endif
