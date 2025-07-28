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

        let messages = memory.getMessages().map {
            ["role": $0.role.rawValue, "content": $0.content]
        }

        guard let openAI = llm as? OpenAIProvider else {
            throw NetworkError.invalidResponse
        }

        let requestBody: [String: Any] = [
            "model": openAI.model,
            "messages": messages
        ]

        let url = URL(string: "\(openAI.baseURL)/chat/completions")!
        let headers = [
            "Authorization": "Bearer \(openAI.apiKey)",
            "Content-Type": "application/json"
        ]

        let response: OpenAIResponse = try await NetworkClient.postUnsafe(
            url: url,
            headers: headers,
            body: requestBody,
            responseType: OpenAIResponse.self
        )

        guard let reply = response.choices.first?.message.content else {
            throw NetworkError.invalidResponse
        }

        memory.addMessage(ChatMessage(role: .assistant, content: reply))
        return reply
    }

   

    public func combine<Next>(with other: Next) -> SequentialChain<ConversationChain, Next>
    where Next: CombinableChain, String == Next.Input {
        SequentialChain(first: self, second: other)
    }
}
