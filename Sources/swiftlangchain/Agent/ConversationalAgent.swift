//
//  ConversationalAgent.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Conversational Agent
/// Maintains conversation history and can use tools in a conversational context
public final class ConversationalAgent: CombinableAgent {
    public typealias Input = String
    public typealias Output = String
    
    private let llm: LLMProvider
    public let tools: [any Tool]
    private var memory: ContextMemory?
    private let verbose: Bool
    
    public var description: String {
        return "Conversational Agent with \(tools.count) tools"
    }
    
    public init(
        llm: LLMProvider,
        tools: [any Tool] = [],
        memory: ContextMemory? = nil,
        verbose: Bool = false
    ) {
        self.llm = llm
        self.tools = tools
        self.memory = memory
        self.verbose = verbose
    }
    
    public func run(_ input: Input) async throws -> Output {
        // Add user input to memory if available
        if var memory = memory {
            memory.addMessage(ChatMessage(role: .user, content: input))
            self.memory = memory
        }
        
        // Get conversation context
        let context = memory?.asPromptContext() ?? ""
        
        // Create prompt with conversation history and tools
        let prompt = createConversationalPrompt(
            input: input,
            context: context,
            tools: tools
        )
        
        // Generate response
        let response = try await llm.generate(prompt: prompt)
        
        // Check if response indicates tool usage
        if response.contains("USE_TOOL:") {
            return try await handleToolUsage(response: response, input: input)
        }
        
        // Add response to memory if available
        if var memory = memory {
            memory.addMessage(ChatMessage(role: .assistant, content: response))
            self.memory = memory
        }
        
        if verbose {
            print("💬 Response: \(response)")
        }
        
        return response
    }
    
    
    
    // MARK: - Private Methods
    
    private func createConversationalPrompt(input: String, context: String, tools: [any Tool]) -> String {
        let toolsDescription = tools.map { "- \($0.name): \($0.description)" }.joined(separator: "\n")
        
        let contextSection = context.isEmpty ? "" : """
        
        Conversation history:
        \(context)
        """
        
        return """
        You are a helpful conversational AI assistant. You can have natural conversations and use tools when needed.
        
        Available tools:
        \(toolsDescription)
        
        If you need to use a tool, respond with:
        USE_TOOL: tool_name
        INPUT: input_for_tool
        
        Otherwise, respond naturally to the user's message.
        \(contextSection)
        
        User: \(input)
        Assistant:
        """
    }
    
    private func handleToolUsage(response: String, input: String) async throws -> String {
        // Parse tool usage from response
        let lines = response.components(separatedBy: .newlines)
        var toolName = ""
        var toolInput = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("USE_TOOL:") {
                toolName = String(trimmed.dropFirst("USE_TOOL:".count)).trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("INPUT:") {
                toolInput = String(trimmed.dropFirst("INPUT:".count)).trimmingCharacters(in: .whitespaces)
            }
        }
        
        guard !toolName.isEmpty else {
            throw AgentError.invalidResponseFormat(response)
        }
        
        // Execute the tool
        let toolResult = try await executeTool(toolName, input: toolInput)
        
        // Generate a conversational response about the tool result
        let followUpPrompt = """
        The user asked: \(input)
        
        You used the \(toolName) tool with input: \(toolInput)
        The result was: \(toolResult)
        
        Provide a natural, conversational response that incorporates this information:
        """
        
        let finalResponse = try await llm.generate(prompt: followUpPrompt)
        
        // Add to memory if available
        if var memory = memory {
            memory.addMessage(ChatMessage(role: .assistant, content: finalResponse))
            self.memory = memory
        }
        
        if verbose {
            print("🔧 Used tool: \(toolName)")
            print("📝 Tool input: \(toolInput)")
            print("✅ Tool result: \(toolResult)")
            print("💬 Final response: \(finalResponse)")
        }
        
        return finalResponse
    }
    
    private func executeTool(_ toolName: String, input: String) async throws -> String {
        guard let tool = tools.first(where: { $0.name == toolName }) else {
            throw AgentError.toolNotFound(toolName)
        }
        
        return try await tool.execute(input)
    }
} 
