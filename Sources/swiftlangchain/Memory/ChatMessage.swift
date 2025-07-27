//
//  ChatMessage.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


public struct ChatMessage {
    public enum Role: String {
        case system, user, assistant
    }
    
    public let role: Role
    public let content: String
    
    public init(role: Role, content: String) {
        self.role = role
        self.content = content
    }
}
