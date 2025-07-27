//
//  SequentialChain.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


import Foundation

//public protocol Chain {
//    associatedtype Input
//    associatedtype Output
//    func run(_ input: Input) async throws -> Output
//}

/// A chain that sequentially runs two chains: firstChain -> secondChain
public struct SequentialChain<
    C1: Chain,
    C2: Chain
>: Chain where C1.Output == C2.Input {
    
    public typealias Input = C1.Input
    public typealias Output = C2.Output
    
    private let firstChain: C1
    private let secondChain: C2
    
    public init(first: C1, second: C2) {
        self.firstChain = first
        self.secondChain = second
    }
    
    public func run(_ input: C1.Input) async throws -> C2.Output {
        let intermediate = try await firstChain.run(input)
        return try await secondChain.run(intermediate)
    }
}
