//
//  PlanAndExecuteAgent.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Plan-and-Execute Agent
/// First creates a plan, then executes it step by step
public struct PlanAndExecuteAgent: Agent, CombinableAgent {
    public typealias Input = String
    public typealias Output = String
    
    private let llm: LLMProvider
    public let tools: [any Tool]
    private let verbose: Bool
    
    public var description: String {
        return "Plan-and-Execute Agent with \(tools.count) tools"
    }
    
    public init(
        llm: LLMProvider,
        tools: [any Tool] = [],
        verbose: Bool = false
    ) {
        self.llm = llm
        self.tools = tools
        self.verbose = verbose
    }
    
    public func run(_ input: Input) async throws -> Output {
        let startTime = Date()
        
        // Step 1: Create a plan
        let plan = try await createPlan(input: input)
        
        if verbose {
            print("📋 Plan created:")
            for (index, step) in plan.enumerated() {
                print("  \(index + 1). \(step)")
            }
            print("---")
        }
        
        // Step 2: Execute the plan
        var results: [String] = []
        var steps: [AgentStep] = []
        
        for (index, step) in plan.enumerated() {
            if verbose {
                print("🔄 Executing step \(index + 1): \(step)")
            }
            
            let result = try await executePlanStep(step, previousResults: results)
            results.append(result)
            
            let agentStep = AgentStep(
                thought: "Executing plan step \(index + 1)",
                action: "execute_plan_step",
                actionInput: step,
                observation: result
            )
            steps.append(agentStep)
            
            if verbose {
                print("✅ Result: \(result)")
                print("---")
            }
        }
        
        // Step 3: Generate final answer
        let finalAnswer = try await generateFinalAnswer(input: input, plan: plan, results: results)
        
        let executionTime = Date().timeIntervalSince(startTime)
        if verbose {
            print("🎯 Final Answer: \(finalAnswer)")
            print("⏱️ Execution time: \(String(format: "%.2f", executionTime))s")
        }
        
        return finalAnswer
    }
    
    public func combine<A: CombinableAgent>(with other: A) -> MultiAgent<Self, A> {
        return MultiAgent(first: self, second: other)
    }
    
    // MARK: - Private Methods
    
    private func createPlan(input: String) async throws -> [String] {
        let toolsDescription = tools.map { "- \($0.name): \($0.description)" }.joined(separator: "\n")
        
        let prompt = """
        Create a step-by-step plan to answer the following question using the available tools.
        
        Available tools:
        \(toolsDescription)
        
        Question: \(input)
        
        Respond with a numbered list of steps. Each step should be clear and actionable.
        Format your response as:
        1. First step
        2. Second step
        3. Third step
        etc.
        """
        
        let response = try await llm.generate(prompt: prompt)
        
        // Parse numbered list
        let lines = response.components(separatedBy: .newlines)
        var plan: [String] = []
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let range = trimmed.range(of: #"^\d+\.\s*(.+)"#, options: .regularExpression) {
                let step = String(trimmed[range]).trimmingCharacters(in: .whitespaces)
                plan.append(step)
            }
        }
        
        guard !plan.isEmpty else {
            throw AgentError.planningFailed("Failed to create a valid plan")
        }
        
        return plan
    }
    
    private func executePlanStep(_ step: String, previousResults: [String]) async throws -> String {
        // Determine which tool to use based on the step description
        let toolName = try determineToolForStep(step)
        
        guard let tool = tools.first(where: { $0.name == toolName }) else {
            throw AgentError.toolNotFound(toolName)
        }
        
        // Create input for the tool based on the step and previous results
        let toolInput = createToolInput(step: step, previousResults: previousResults)
        
        return try await tool.execute(toolInput)
    }
    
    private func determineToolForStep(_ step: String) throws -> String {
        // Simple heuristic to determine which tool to use
        let stepLower = step.lowercased()
        
        if stepLower.contains("search") || stepLower.contains("find") || stepLower.contains("look up") {
            return "search"
        } else if stepLower.contains("calculate") || stepLower.contains("math") || stepLower.contains("compute") {
            return "calculator"
        } else if stepLower.contains("weather") || stepLower.contains("temperature") {
            return "weather"
        } else if stepLower.contains("database") || stepLower.contains("query") {
            return "database"
        } else {
            // Default to search if no specific tool is identified
            return "search"
        }
    }
    
    private func createToolInput(step: String, previousResults: [String]) -> String {
        if previousResults.isEmpty {
            return step
        } else {
            return "Step: \(step)\nPrevious results: \(previousResults.joined(separator: "; "))"
        }
    }
    
    private func generateFinalAnswer(input: String, plan: [String], results: [String]) async throws -> String {
        let prompt = """
        Based on the original question and the results from executing the plan, provide a comprehensive final answer.
        
        Original question: \(input)
        
        Plan executed:
        \(plan.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        
        Results:
        \(results.enumerated().map { "\($0 + 1). \($1)" }.joined(separator: "\n"))
        
        Provide a clear, comprehensive answer that addresses the original question using the information gathered:
        """
        
        return try await llm.generate(prompt: prompt)
    }
} 