//
//  ReActAgent.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// ReAct Agent (Reasoning + Acting)
/// Follows the ReAct pattern: Reason about what to do, then Act using tools
public struct ReActAgent: Agent, CombinableAgent {
    public typealias Input = String
    public typealias Output = String
    
    private let llm: LLMProvider
    public let tools: [any Tool]
    private let maxIterations: Int
    private let verbose: Bool
    
    public var description: String {
        return "ReAct Agent with \(tools.count) tools"
    }
    
    public init(
        llm: LLMProvider,
        tools: [any Tool] = [],
        maxIterations: Int = 10,
        verbose: Bool = false
    ) {
        self.llm = llm
        self.tools = tools
        self.maxIterations = maxIterations
        self.verbose = verbose
    }
    
    public func run(_ input: Input) async throws -> Output {
        let startTime = Date()
        var steps: [AgentStep] = []
        var currentInput = input
        
        for iteration in 1...maxIterations {
            if verbose {
                print("🔄 Iteration \(iteration)/\(maxIterations)")
            }
            
            // Step 1: Generate thought and action
            let prompt = createReActPrompt(input: currentInput, tools: tools, steps: steps)
            let response = try await llm.generate(prompt: prompt)
            
            // Step 2: Parse the response
            let parsed = try parseReActResponse(response)
            
            // Step 3: Execute action if needed
            var observation: String?
            if parsed.action != "Final Answer" {
                observation = try await executeAction(parsed.action, input: parsed.actionInput)
            }
            
            // Step 4: Create step
            let step = AgentStep(
                thought: parsed.thought,
                action: parsed.action,
                actionInput: parsed.actionInput,
                observation: observation
            )
            steps.append(step)
            
            if verbose {
                print("🧠 Thought: \(parsed.thought)")
                print("🔧 Action: \(parsed.action)")
                print("📝 Input: \(parsed.actionInput)")
                if let obs = observation {
                    print("👁️ Observation: \(obs)")
                }
                print("---")
            }
            
            // Step 5: Check if we have a final answer
            if parsed.action == "Final Answer" {
                let executionTime = Date().timeIntervalSince(startTime)
                if verbose {
                    print("✅ Final Answer: \(parsed.actionInput)")
                    print("⏱️ Execution time: \(String(format: "%.2f", executionTime))s")
                }
                return parsed.actionInput
            }
            
            // Step 6: Update context for next iteration
            currentInput = "Previous observation: \(observation ?? "No observation")\nQuestion: \(input)"
        }
        
        throw AgentError.maxIterationsExceeded(maxIterations)
    }
    
    public func combine<A: CombinableAgent>(with other: A) -> MultiAgent<Self, A> {
        return MultiAgent(first: self, second: other)
    }
    
    // MARK: - Private Methods
    
    private func createReActPrompt(input: String, tools: [any Tool], steps: [AgentStep]) -> String {
        let toolsDescription = tools.map { "- \($0.name): \($0.description)" }.joined(separator: "\n")
        
        let stepsHistory = steps.map { step in
            """
            Thought: \(step.thought)
            Action: \(step.action)
            Action Input: \(step.actionInput)
            Observation: \(step.observation ?? "No observation")
            """
        }.joined(separator: "\n\n")
        
        return """
        You are a helpful AI assistant that can use tools to answer questions.
        
        Available tools:
        \(toolsDescription)
        
        To use a tool, respond with:
        Thought: I need to think about what to do
        Action: tool_name
        Action Input: input_for_tool
        
        When you have the final answer, respond with:
        Thought: I have the final answer
        Action: Final Answer
        Action Input: your_final_answer
        
        Previous steps:
        \(stepsHistory)
        
        Question: \(input)
        
        Let's approach this step by step:
        """
    }
    
    private func parseReActResponse(_ response: String) throws -> (thought: String, action: String, actionInput: String) {
        let lines = response.components(separatedBy: .newlines)
        var thought = ""
        var action = ""
        var actionInput = ""
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("Thought:") {
                thought = String(trimmed.dropFirst("Thought:".count)).trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("Action:") {
                action = String(trimmed.dropFirst("Action:".count)).trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("Action Input:") {
                actionInput = String(trimmed.dropFirst("Action Input:".count)).trimmingCharacters(in: .whitespaces)
            }
        }
        
        guard !thought.isEmpty && !action.isEmpty else {
            throw AgentError.invalidResponseFormat(response)
        }
        
        return (thought, action, actionInput)
    }
    
    private func executeAction(_ actionName: String, input: String) async throws -> String {
        guard let tool = tools.first(where: { $0.name == actionName }) else {
            throw AgentError.toolNotFound(actionName)
        }
        
        return try await tool.execute(input)
    }
} 