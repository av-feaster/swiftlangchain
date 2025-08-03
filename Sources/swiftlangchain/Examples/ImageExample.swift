//
//  ImageExample.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Example demonstrating image message support
public struct ImageExample {
    
    /// Example: Analyze an image with text prompt
    public static func analyzeImageWithText() async throws {
        print("🔍 Analyzing image with text prompt...")
        
        let openAI = OpenAIProvider(
            apiKey: "your-api-key-here",
            model: "gpt-4-vision-preview"
        )
        
        let memory = ContextMemory(
            maxTokens: 4000,
            maxMessages: 10,
            model: .gpt4
        )
        
        let conversation = ConversationChain(llm: openAI, memory: memory)
        
        // Example: Analyze an image with a text prompt
        let response = try await conversation.runWithImage(
            "What do you see in this image?",
            imageUrl: "https://example.com/image.jpg",
            imageDetail: "high" // "low", "high", or "auto"
        )
        
        print("📸 Analysis: \(response)")
    }
    
    /// Example: Analyze image only (no text prompt)
    public static func analyzeImageOnly() async throws {
        print("🔍 Analyzing image only...")
        
        let openAI = OpenAIProvider(
            apiKey: "your-api-key-here",
            model: "gpt-4-vision-preview"
        )
        
        let memory = ContextMemory(
            maxTokens: 4000,
            maxMessages: 10,
            model: .gpt4
        )
        
        let conversation = ConversationChain(llm: openAI, memory: memory)
        
        // Example: Analyze an image without text prompt
        let response = try await conversation.runWithImageOnly(
            "https://example.com/image.jpg",
            imageDetail: "auto"
        )
        
        print("📸 Analysis: \(response)")
    }
    
    /// Example: Using ConversationalAgent with images
    public static func conversationalAgentWithImage() async throws {
        print("🤖 Using ConversationalAgent with image...")
        
        let openAI = OpenAIProvider(
            apiKey: "your-api-key-here",
            model: "gpt-4-vision-preview"
        )
        
        let memory = ContextMemory(
            maxTokens: 4000,
            maxMessages: 10,
            model: .gpt4
        )
        
        let agent = ConversationalAgent(
            llm: openAI,
            tools: [],
            memory: memory,
            verbose: true
        )
        
        // Create a message with both text and image
        let message = ChatMessage(
            role: .user,
            text: "What's in this image?",
            imageUrl: "https://example.com/image.jpg",
            imageDetail: "high"
        )
        
        // Add to memory manually
        var updatedMemory = memory
        updatedMemory.addMessage(message)
        
        // Run the agent
        let response = try await agent.run("Please analyze the image I just shared.")
        
        print("🤖 Agent response: \(response)")
    }
    
    /// Example: Direct OpenAI provider usage with images
    public static func directOpenAIWithImages() async throws {
        print("🔧 Direct OpenAI provider with images...")
        
        let openAI = OpenAIProvider(
            apiKey: "your-api-key-here",
            model: "gpt-4-vision-preview"
        )
        
        // Create messages with images
        let messages: [ChatMessage] = [
            ChatMessage(role: .system, content: "You are a helpful assistant that can analyze images."),
            ChatMessage(
                role: .user,
                text: "What do you see in this image?",
                imageUrl: "https://example.com/image.jpg",
                imageDetail: "high"
            )
        ]
        
        let response = try await openAI.generateWithMessages(messages)
        
        print("📸 Direct response: \(response)")
    }
    
    /// Example: Multiple images in one message
    public static func multipleImages() async throws {
        print("🖼️ Multiple images in one message...")
        
        let openAI = OpenAIProvider(
            apiKey: "your-api-key-here",
            model: "gpt-4-vision-preview"
        )
        
        // Create a message with multiple content items
        let textItem = ChatMessage.ContentItem(text: "Compare these two images:")
        let image1Item = ChatMessage.ContentItem(imageUrl: ChatMessage.ImageContent(url: "https://example.com/image1.jpg"))
        let image2Item = ChatMessage.ContentItem(imageUrl: ChatMessage.ImageContent(url: "https://example.com/image2.jpg"))
        
        let message = ChatMessage(
            role: .user,
            content: .mixed([textItem, image1Item, image2Item])
        )
        
        let messages: [ChatMessage] = [
            ChatMessage(role: .system, content: "You are a helpful assistant that can analyze and compare images."),
            message
        ]
        
        let response = try await openAI.generateWithMessages(messages)
        
        print("🖼️ Comparison: \(response)")
    }
} 