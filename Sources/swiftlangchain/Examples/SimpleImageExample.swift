//
//  SimpleImageExample.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

/// Simple example demonstrating image message functionality
public struct SimpleImageExample {
    
    /// Demonstrate creating different types of messages
    public static func demonstrateMessageTypes() {
        print("📝 Demonstrating different message types...")
        
        // 1. Text-only message (backward compatible)
        let textMessage = ChatMessage(role: .user, content: "Hello, how are you?")
        print("Text message: \(textMessage.textContent ?? "No text")")
        print("Image URLs: \(textMessage.imageUrls)")
        
        // 2. Image-only message
        let imageMessage = ChatMessage(role: .user, imageUrl: "https://example.com/image.jpg", imageDetail: "high")
        print("Image message text: \(imageMessage.textContent ?? "No text")")
        print("Image URLs: \(imageMessage.imageUrls)")
        
        // 3. Mixed message (text + image)
        let mixedMessage = ChatMessage(role: .user, text: "Look at this image", imageUrl: "https://example.com/image.jpg", imageDetail: "auto")
        print("Mixed message text: \(mixedMessage.textContent ?? "No text")")
        print("Image URLs: \(mixedMessage.imageUrls)")
        
        // 4. Complex mixed message with multiple content items
        let textItem = ChatMessage.ContentItem(text: "Compare these images:")
        let image1Item = ChatMessage.ContentItem(imageUrl: ChatMessage.ImageContent(url: "https://example.com/image1.jpg", detail: "high"))
        let image2Item = ChatMessage.ContentItem(imageUrl: ChatMessage.ImageContent(url: "https://example.com/image2.jpg", detail: "low"))
        
        let complexMessage = ChatMessage(role: .user, content: .mixed([textItem, image1Item, image2Item]))
        print("Complex message text: \(complexMessage.textContent ?? "No text")")
        print("Complex message image URLs: \(complexMessage.imageUrls)")
    }
    
    /// Demonstrate memory with image messages
    public static func demonstrateMemoryWithImages() {
        print("\n🧠 Demonstrating memory with image messages...")
        
        let memory = ContextMemory(maxTokens: 2000, maxMessages: 5, model: .gpt4)
        
        // Add different types of messages
        var updatedMemory = memory
        updatedMemory.addMessage(ChatMessage(role: .user, content: "Hello"))
        updatedMemory.addMessage(ChatMessage(role: .assistant, content: "Hi there! How can I help you?"))
        updatedMemory.addMessage(ChatMessage(role: .user, text: "Can you analyze this image?", imageUrl: "https://example.com/image.jpg"))
        updatedMemory.addMessage(ChatMessage(role: .assistant, content: "I can see the image you shared. It appears to be..."))
        
        print("Total messages in memory: \(updatedMemory.getMessages().count)")
        print("Memory context (text only):")
        print(updatedMemory.asPromptContext())
    }
    
    /// Demonstrate OpenAI message conversion
    public static func demonstrateOpenAIMessageConversion() {
        print("\n🔄 Demonstrating OpenAI message conversion...")
        
        // Create a ChatMessage
        let chatMessage = ChatMessage(role: .user, text: "What's in this image?", imageUrl: "https://example.com/image.jpg", imageDetail: "high")
        
        // Convert to OpenAIMessage (this would normally be done by the provider)
        let openAIMessage = OpenAIMessage(role: chatMessage.role.rawValue, text: "What's in this image?", imageUrl: "https://example.com/image.jpg", imageDetail: "high")
        
        print("Original ChatMessage role: \(chatMessage.role)")
        print("Converted OpenAIMessage role: \(openAIMessage.role)")
        
        // Test content encoding
        switch openAIMessage.content {
        case .text(let text):
            print("Content type: text - \(text)")
        case .image(let imageUrl):
            print("Content type: image - \(imageUrl.url)")
        case .array(let items):
            print("Content type: array with \(items.count) items")
            for (index, item) in items.enumerated() {
                print("  Item \(index): type=\(item.type), text=\(item.text ?? "nil"), imageUrl=\(item.imageUrl?.url ?? "nil")")
            }
        }
    }
    
    /// Run all demonstrations
    public static func runAll() {
        print("🖼️ SwiftLangChain Image Message Support Demo")
        print("=" * 50)
        
        demonstrateMessageTypes()
        demonstrateMemoryWithImages()
        demonstrateOpenAIMessageConversion()
        
        print("\n✅ Demo completed successfully!")
        print("\nTo use with real images, you would:")
        print("1. Replace 'https://example.com/image.jpg' with actual image URLs")
        print("2. Use a real OpenAI API key")
        print("3. Call conversation.runWithImage() or openAI.generateWithMessages()")
    }
}

// Helper extension for string repetition
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
} 