//
//  AgentBuilder.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Builder for creating agents with a fluent interface
public class AgentBuilder {
    private var llm: LLMProvider?
    private var tools: [any Tool] = []
    private var maxIterations: Int = 10
    private var verbose: Bool = false
    private var agentType: AgentType = .react
    private var memory: ContextMemory?
    
    public enum AgentType {
        case react
        case planAndExecute
        case conversational
    }
    
    public init() {}
    
    /// Set the LLM provider for the agent
    @discardableResult
    public func withLLM(_ llm: LLMProvider) -> AgentBuilder {
        self.llm = llm
        return self
    }
    
    /// Add tools that the agent can use
    @discardableResult
    public func withTools(_ tools: [any Tool]) -> AgentBuilder {
        self.tools = tools
        return self
    }
    
    /// Add a single tool to the agent
    @discardableResult
    public func withTool(_ tool: any Tool) -> AgentBuilder {
        self.tools.append(tool)
        return self
    }
    
    /// Set the maximum number of iterations for the agent
    @discardableResult
    public func withMaxIterations(_ maxIterations: Int) -> AgentBuilder {
        self.maxIterations = maxIterations
        return self
    }
    
    /// Enable or disable verbose logging
    @discardableResult
    public func withVerbose(_ verbose: Bool) -> AgentBuilder {
        self.verbose = verbose
        return self
    }
    
    /// Set the type of agent to create
    @discardableResult
    public func withAgentType(_ agentType: AgentType) -> AgentBuilder {
        self.agentType = agentType
        return self
    }
    
    /// Set memory for the agent
    @discardableResult
    public func withMemory(_ memory: ContextMemory) -> AgentBuilder {
        self.memory = memory
        return self
    }
    
    /// Build the agent with the configured settings
    public func build() throws -> any Agent {
        guard let llm = llm else {
            throw AgentError.executionFailed("LLM provider is required")
        }
        
        switch agentType {
        case .react:
            return ReActAgent(
                llm: llm,
                tools: tools,
                maxIterations: maxIterations,
                verbose: verbose
            )
        case .planAndExecute:
            return PlanAndExecuteAgent(
                llm: llm,
                tools: tools,
                verbose: verbose
            )
        case .conversational:
            return ConversationalAgent(
                llm: llm,
                tools: tools,
                memory: memory,
                verbose: verbose
            )
        }
    }
    
    /// Build a ReAct agent directly
    public func buildReActAgent() throws -> ReActAgent {
        guard let llm = llm else {
            throw AgentError.executionFailed("LLM provider is required")
        }
        
        return ReActAgent(
            llm: llm,
            tools: tools,
            maxIterations: maxIterations,
            verbose: verbose
        )
    }
    
    /// Build a Plan-and-Execute agent directly
    public func buildPlanAndExecuteAgent() throws -> PlanAndExecuteAgent {
        guard let llm = llm else {
            throw AgentError.executionFailed("LLM provider is required")
        }
        
        return PlanAndExecuteAgent(
            llm: llm,
            tools: tools,
            verbose: verbose
        )
    }
    
    /// Build a Conversational agent directly
    public func buildConversationalAgent() throws -> ConversationalAgent {
        guard let llm = llm else {
            throw AgentError.executionFailed("LLM provider is required")
        }
        
        return ConversationalAgent(
            llm: llm,
            tools: tools,
            memory: memory,
            verbose: verbose
        )
    }
}

// MARK: - Convenience Extensions

public extension AgentBuilder {
    /// Create a ReAct agent with default settings
    static func reactAgent(llm: LLMProvider, tools: [any Tool] = []) -> ReActAgent {
        return ReActAgent(
            llm: llm,
            tools: tools,
            maxIterations: 10,
            verbose: false
        )
    }
    
    /// Create a Plan-and-Execute agent with default settings
    static func planAndExecuteAgent(llm: LLMProvider, tools: [any Tool] = []) -> PlanAndExecuteAgent {
        return PlanAndExecuteAgent(
            llm: llm,
            tools: tools,
            verbose: false
        )
    }
    
    /// Create a Conversational agent with default settings
    static func conversationalAgent(llm: LLMProvider, tools: [any Tool] = [], memory: ContextMemory? = nil) -> ConversationalAgent {
        return ConversationalAgent(
            llm: llm,
            tools: tools,
            memory: memory,
            verbose: false
        )
    }
}

// MARK: - Agent Protocol and Types

/// Core agent protocol that defines the interface for all agents
public protocol Agent {
    associatedtype Input
    associatedtype Output
    
    /// Execute the agent with the given input
    func run(_ input: Input) async throws -> Output
    
    /// Get the agent's available tools
    var tools: [any Tool] { get }
    
    /// Get the agent's description
    var description: String { get }
}

/// Agent that can be combined with other agents
public protocol CombinableAgent: Agent {
    /// Combine this agent with another agent
    func combine<A: CombinableAgent>(with other: A) -> MultiAgent<Self, A>
    where Self.Output == A.Input
}

public extension CombinableAgent {
    func combine<A: CombinableAgent>(
        with other: A
    ) -> MultiAgent<Self, A> where Self.Output == A.Input {
        return MultiAgent(first: self, second: other)
    }
}


/// Agent execution context
public struct AgentContext {
    public let input: String
    public let availableTools: [any Tool]
    public let memory: ContextMemory?
    public let maxIterations: Int
    public let verbose: Bool
    
    public init(
        input: String,
        availableTools: [any Tool] = [],
        memory: ContextMemory? = nil,
        maxIterations: Int = 10,
        verbose: Bool = false
    ) {
        self.input = input
        self.availableTools = availableTools
        self.memory = memory
        self.maxIterations = maxIterations
        self.verbose = verbose
    }
}

/// Agent execution step
public struct AgentStep {
    public let thought: String
    public let action: String
    public let actionInput: String
    public let observation: String?
    public let finalAnswer: String?
    public let timestamp: Date
    
    public init(
        thought: String,
        action: String,
        actionInput: String,
        observation: String? = nil,
        finalAnswer: String? = nil,
        timestamp: Date = Date()
    ) {
        self.thought = thought
        self.action = action
        self.actionInput = actionInput
        self.observation = observation
        self.finalAnswer = finalAnswer
        self.timestamp = timestamp
    }
}

/// Agent execution result
public struct AgentResult {
    public let output: String
    public let steps: [AgentStep]
    public let iterations: Int
    public let success: Bool
    public let error: Error?
    public let executionTime: TimeInterval
    
    public init(
        output: String,
        steps: [AgentStep] = [],
        iterations: Int = 0,
        success: Bool = true,
        error: Error? = nil,
        executionTime: TimeInterval = 0
    ) {
        self.output = output
        self.steps = steps
        self.iterations = iterations
        self.success = success
        self.error = error
        self.executionTime = executionTime
    }
}

// MARK: - Agent Errors

/// Errors that can occur during agent execution
public enum AgentError: Error, LocalizedError {
    case maxIterationsExceeded(Int)
    case toolNotFound(String)
    case invalidResponseFormat(String)
    case planningFailed(String)
    case executionFailed(String)
    case invalidToolInput(String)
    case memoryRequired
    case llmNotConfigured
    
    public var errorDescription: String? {
        switch self {
        case .maxIterationsExceeded(let max):
            return "Agent exceeded maximum iterations (\(max))"
        case .toolNotFound(let toolName):
            return "Tool '\(toolName)' not found"
        case .invalidResponseFormat(let response):
            return "Invalid response format: \(response)"
        case .planningFailed(let reason):
            return "Planning failed: \(reason)"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        case .invalidToolInput(let input):
            return "Invalid tool input: \(input)"
        case .memoryRequired:
            return "Memory is required for this agent type"
        case .llmNotConfigured:
            return "LLM provider is not configured"
        }
    }
} 
