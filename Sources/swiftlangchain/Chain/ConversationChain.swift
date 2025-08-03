//
//  ConversationChain.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

public final class ConversationChain: Chain {
    
    public typealias Input = String
    public typealias Output = String

    private var memory: ContextMemory
    private let llm: LLMProvider

    public init(llm: LLMProvider, memory: ContextMemory) {
        self.llm = llm
        self.memory = memory
    }
    
    public func run(_ input: String) async throws -> String {
        memory.addMessage(ChatMessage(role: .user, content: input))

        guard let openAI = llm as? OpenAIProvider else {
            throw NetworkError.invalidResponse
        }

        let messages = memory.getMessages()
        let response = try await openAI.generateWithMessages(messages)

        memory.addMessage(ChatMessage(role: .assistant, content: response))
        return response
    }
    
    /// Run with image support
    public func runWithImage(_ input: String, imageUrl: String, imageDetail: String? = nil) async throws -> String {
        let message = ChatMessage(role: .user, text: input, imageUrl: imageUrl, imageDetail: imageDetail)
        memory.addMessage(message)

        guard let openAI = llm as? OpenAIProvider else {
            throw NetworkError.invalidResponse
        }

        let messages = memory.getMessages()
        let response = try await openAI.generateWithMessages(messages)

        memory.addMessage(ChatMessage(role: .assistant, content: response))
        return response
    }
    
    /// Run with image only (no text)
    public func runWithImageOnly(_ imageUrl: String, imageDetail: String? = nil) async throws -> String {
        let message = ChatMessage(role: .user, imageUrl: imageUrl, imageDetail: imageDetail)
        memory.addMessage(message)

        guard let openAI = llm as? OpenAIProvider else {
            throw NetworkError.invalidResponse
        }

        let messages = memory.getMessages()
        let response = try await openAI.generateWithMessages(messages)

        memory.addMessage(ChatMessage(role: .assistant, content: response))
        return response
    }

    /// Run with base64 image support
    public func runWithBase64Image(_ input: String, imageBase64: String, imageDetail: String? = nil) async throws -> String {
        let message = ChatMessage(role: .user, text: input, imageBase64: imageBase64, imageDetail: imageDetail)
        memory.addMessage(message)

        guard let openAI = llm as? OpenAIProvider else {
            throw NetworkError.invalidResponse
        }

        let messages = memory.getMessages()
        let response = try await openAI.generateWithMessages(messages)

        memory.addMessage(ChatMessage(role: .assistant, content: response))
        return response
    }

    /// Run with base64 image only (no text)
    public func runWithBase64ImageOnly(_ imageBase64: String, imageDetail: String? = nil) async throws -> String {
        let message = ChatMessage(role: .user, imageBase64: imageBase64, imageDetail: imageDetail)
        memory.addMessage(message)

        guard let openAI = llm as? OpenAIProvider else {
            throw NetworkError.invalidResponse
        }

        let messages = memory.getMessages()
        let response = try await openAI.generateWithMessages(messages)

        memory.addMessage(ChatMessage(role: .assistant, content: response))
        return response
    }

    public func combine<Next>(with other: Next) -> SequentialChain<ConversationChain, Next>
    where Next: CombinableChain, String == Next.Input {
        SequentialChain(first: self, second: other)
    }
}
