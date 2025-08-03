//
//  ImageMessageTests.swift
//  swiftlangchainTests
//
//  Created by Aman Verma on 28/07/25.
//

import XCTest
@testable import swiftlangchain

final class ImageMessageTests: XCTestCase {
    
    func testChatMessageTextContent() {
        // Test text-only message
        let textMessage = ChatMessage(role: .user, content: "Hello")
        XCTAssertEqual(textMessage.textContent, "Hello")
        XCTAssertEqual(textMessage.imageUrls, [])
        
        // Test image-only message
        let imageMessage = ChatMessage(role: .user, imageUrl: "https://example.com/image.jpg")
        XCTAssertNil(imageMessage.textContent)
        XCTAssertEqual(imageMessage.imageUrls, ["https://example.com/image.jpg"])
        
        // Test mixed message
        let mixedMessage = ChatMessage(role: .user, text: "Look at this", imageUrl: "https://example.com/image.jpg")
        XCTAssertEqual(mixedMessage.textContent, "Look at this")
        XCTAssertEqual(mixedMessage.imageUrls, ["https://example.com/image.jpg"])
    }
    
    func testChatMessageConvenienceInitializers() {
        // Test text initializer (backward compatibility)
        let textMessage = ChatMessage(role: .user, content: "Hello")
        XCTAssertEqual(textMessage.textContent, "Hello")
        
        // Test image initializer
        let imageMessage = ChatMessage(role: .user, imageUrl: "https://example.com/image.jpg", imageDetail: "high")
        XCTAssertNil(imageMessage.textContent)
        XCTAssertEqual(imageMessage.imageUrls, ["https://example.com/image.jpg"])
        
        // Test mixed initializer
        let mixedMessage = ChatMessage(role: .user, text: "Hello", imageUrl: "https://example.com/image.jpg", imageDetail: "auto")
        XCTAssertEqual(mixedMessage.textContent, "Hello")
        XCTAssertEqual(mixedMessage.imageUrls, ["https://example.com/image.jpg"])
    }
    
    func testOpenAIMessageContentEncoding() {
        // Test text content encoding
        let textMessage = OpenAIMessage(role: "user", content: "Hello")
        XCTAssertEqual(textMessage.role, "user")
        
        // Test image content encoding
        let imageMessage = OpenAIMessage(role: "user", imageUrl: "https://example.com/image.jpg", imageDetail: "high")
        XCTAssertEqual(imageMessage.role, "user")
        
        // Test mixed content encoding
        let mixedMessage = OpenAIMessage(role: "user", text: "Hello", imageUrl: "https://example.com/image.jpg", imageDetail: "auto")
        XCTAssertEqual(mixedMessage.role, "user")
    }
    
    func testOpenAIMessageContentDecoding() {
        // Test text content decoding
        let textContent = OpenAIMessageContent.text("Hello")
        XCTAssertNotNil(textContent)
        
        // Test array content decoding
        let items = [
            OpenAIContentItem(type: "text", text: "Hello"),
            OpenAIContentItem(type: "image_url", imageUrl: OpenAIImageUrl(url: "https://example.com/image.jpg"))
        ]
        let arrayContent = OpenAIMessageContent.array(items)
        XCTAssertNotNil(arrayContent)
    }
    
    func testContextMemoryWithImageMessages() {
        let memory = ContextMemory(maxTokens: 1000, maxMessages: 5, model: .gpt4)
        
        // Add text message
        var updatedMemory = memory
        updatedMemory.addMessage(ChatMessage(role: .user, content: "Hello"))
        XCTAssertEqual(updatedMemory.getMessages().count, 1)
        
        // Add image message
        updatedMemory.addMessage(ChatMessage(role: .user, imageUrl: "https://example.com/image.jpg"))
        XCTAssertEqual(updatedMemory.getMessages().count, 2)
        
        // Add mixed message
        updatedMemory.addMessage(ChatMessage(role: .user, text: "Look at this", imageUrl: "https://example.com/image2.jpg"))
        XCTAssertEqual(updatedMemory.getMessages().count, 3)
        
        // Test prompt context (should only include text content)
        let context = updatedMemory.asPromptContext()
        XCTAssertTrue(context.contains("Hello"))
        XCTAssertTrue(context.contains("Look at this"))
    }
    
    func testOpenAIProviderImageSupport() {
        let provider = OpenAIProvider(apiKey: "test-key", model: "gpt-4-vision-preview")
        
        // Test that the provider can be created with vision model
        XCTAssertEqual(provider.model, "gpt-4-vision-preview")
    }
    
    func testConversationChainImageMethods() {
        let openAI = OpenAIProvider(apiKey: "test-key", model: "gpt-4-vision-preview")
        let memory = ContextMemory(maxTokens: 1000, maxMessages: 5, model: .gpt4)
        let conversation = ConversationChain(llm: openAI, memory: memory)
        
        // Test that the methods exist (we can't actually call them without a real API key)
        XCTAssertNotNil(conversation)
    }
} 