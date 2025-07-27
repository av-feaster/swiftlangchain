//
//  Chain.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


import Foundation

/// Protocol for all chain implementations
public protocol Chain {
    associatedtype Input
    associatedtype Output
    
    /// Execute the chain with the given input
    func run(_ input: Input) async throws -> Output
}

/// Protocol for chains that can be combined
public protocol CombinableChain: Chain {
    /// Combine this chain with another chain, where the output of `self` matches the input of `other`.
    func combine<Next: CombinableChain>(
        with other: Next
    ) -> SequentialChain<Self, Next>
    where Self.Output == Next.Input
}
