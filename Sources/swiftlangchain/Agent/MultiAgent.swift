//
//  MultiAgent.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Agent that combines two other agents
public struct MultiAgent<A1: CombinableAgent, A2: CombinableAgent>: Agent 
where A1.Output == A2.Input {
    
    public typealias Input = A1.Input
    public typealias Output = A2.Output
    
    private let first: A1
    private let second: A2
    
    public var tools: [any Tool] {
        return first.tools + second.tools
    }
    
    public var description: String {
        return "MultiAgent: \(first.description) -> \(second.description)"
    }
    
    public init(first: A1, second: A2) {
        self.first = first
        self.second = second
    }
    
    public func run(_ input: Input) async throws -> Output {
        if verbose {
            print("🔄 MultiAgent: Executing first agent")
        }
        
        let intermediate = try await first.run(input)
        
        if verbose {
            print("🔄 MultiAgent: Executing second agent")
        }
        
        return try await second.run(intermediate)
    }
    
    private var verbose: Bool {
        // This would need to be passed through from the individual agents
        return false
    }
}

// MARK: - Agent Composition Extensions

public extension ReActAgent {
    func then<A: CombinableAgent>(_ agent: A) -> MultiAgent<Self, A> {
        return MultiAgent(first: self, second: agent)
    }
}

public extension PlanAndExecuteAgent {
    func then<A: CombinableAgent>(_ agent: A) -> MultiAgent<Self, A> {
        return MultiAgent(first: self, second: agent)
    }
}



// MARK: - Agent Chain Builder

/// Builder for creating chains of agents
public class AgentChainBuilder {
    private var agents: [any Agent] = []
    
    public init() {}
    
    @discardableResult
    public func add<A: Agent>(_ agent: A) -> AgentChainBuilder {
        agents.append(agent)
        return self
    }
    
    public func build() -> [any Agent] {
        return agents
    }
}

// MARK: - Agent Registry

/// Registry for managing available agents
public actor AgentRegistry {
    private var agents: [String: any Agent] = [:]
    
    public static let shared = AgentRegistry()
    
    private init() {}
    
    /// Register an agent with a name
    public func register<A: Agent>(_ agent: A, name: String) {
        agents[name] = agent
    }
    
    /// Get an agent by name
    public func getAgent(named name: String) -> (any Agent)? {
        return agents[name]
    }
    
    /// Get all registered agents
    public func getAllAgents() -> [any Agent] {
        return Array(agents.values)
    }
    
    /// Clear all registered agents
    public func clear() {
        agents.removeAll()
    }
} 