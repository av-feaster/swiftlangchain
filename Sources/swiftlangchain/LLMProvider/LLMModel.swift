//
//  LLMModel.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


public enum LLMModel {
    case gpt3
    case gpt4
    case mistral
    case custom(charactersPerToken: Int)
    
    var estimatedCharactersPerToken: Int {
        switch self {
        case .gpt3: return 4
        case .gpt4: return 3
        case .mistral: return 3
        case .custom(let cpt): return cpt
        }
    }
}
