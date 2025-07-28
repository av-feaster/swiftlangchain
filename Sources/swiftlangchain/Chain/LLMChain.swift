//
//  LLMChain.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


import Foundation

/// Basic chain that combines a prompt template with an LLM provider
public struct LLMChain: Chain, CombinableChain {
    
    public typealias Input = [String: String]
    public typealias Output = String
    
    private let promptTemplate: PromptTemplate
    private let llmProvider: LLMProvider
    private let parameters: GenerationParameters
    
    public init(
        promptTemplate: PromptTemplate,
        llmProvider: LLMProvider,
        parameters: GenerationParameters = GenerationParameters()
    ) {
        self.promptTemplate = promptTemplate
        self.llmProvider = llmProvider
        self.parameters = parameters
    }
    
    public func run(_ input: Input) async throws -> Output {
        let formattedPrompt = try promptTemplate.format(input)
        return try await llmProvider.generate(prompt: formattedPrompt, parameters: parameters)
    }
    
    public func combine<Next>(with other: Next) -> SequentialChain<LLMChain, Next> where Next : CombinableChain, String == Next.Input {
        return SequentialChain.init(first: self, second: other)
    }
    
}
