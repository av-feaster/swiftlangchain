//
//  ChatMessage.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation

public struct ChatMessage {
    public enum Role: String {
        case system, user, assistant
    }
    
    public enum ContentType {
        case text(String)
        case image(ImageContent)
        case mixed([ContentItem])
    }
    
    public struct ImageContent {
        public let url: String?
        public let base64: String?
        public let detail: String? // "low", "high", or "auto"
        
        // Initialize with URL
        public init(url: String, detail: String? = nil) {
            self.url = url
            self.base64 = nil
            self.detail = detail
        }
        
        // Initialize with base64 data
        public init(base64: String, detail: String? = nil) {
            self.url = nil
            self.base64 = base64
            self.detail = detail
        }
        
        // Validate that either URL or base64 is provided
        public var isValid: Bool {
            return (url != nil) != (base64 != nil) // XOR: exactly one should be non-nil
        }
    }
    
    public struct ContentItem {
        public let type: String // "text" or "image_url"
        public let text: String?
        public let imageUrl: ImageContent?
        
        public init(text: String) {
            self.type = "text"
            self.text = text
            self.imageUrl = nil
        }
        
        public init(imageUrl: ImageContent) {
            self.type = "image_url"
            self.text = nil
            self.imageUrl = imageUrl
        }
    }
    
    public let role: Role
    public let content: ContentType
    
    // Convenience initializer for text-only messages (backward compatibility)
    public init(role: Role, content: String) {
        self.role = role
        self.content = .text(content)
    }
    
    // Initializer for mixed content (text + images)
    public init(role: Role, content: ContentType) {
        self.role = role
        self.content = content
    }
    
    // Convenience initializer for image-only messages (URL)
    public init(role: Role, imageUrl: String, imageDetail: String? = nil) {
        self.role = role
        self.content = .image(ImageContent(url: imageUrl, detail: imageDetail))
    }
    
    // Convenience initializer for image-only messages (base64)
    public init(role: Role, imageBase64: String, imageDetail: String? = nil) {
        self.role = role
        self.content = .image(ImageContent(base64: imageBase64, detail: imageDetail))
    }
    
    // Convenience initializer for mixed content (text + image URL)
    public init(role: Role, text: String, imageUrl: String, imageDetail: String? = nil) {
        self.role = role
        let items: [ContentItem] = [
            ContentItem(text: text),
            ContentItem(imageUrl: ImageContent(url: imageUrl, detail: imageDetail))
        ]
        self.content = .mixed(items)
    }
    
    // Convenience initializer for mixed content (text + base64 image)
    public init(role: Role, text: String, imageBase64: String, imageDetail: String? = nil) {
        self.role = role
        let items: [ContentItem] = [
            ContentItem(text: text),
            ContentItem(imageUrl: ImageContent(base64: imageBase64, detail: imageDetail))
        ]
        self.content = .mixed(items)
    }
    
    // Helper method to get text content (for backward compatibility)
    public var textContent: String? {
        switch content {
        case .text(let text):
            return text
        case .image:
            return nil
        case .mixed(let items):
            return items.compactMap { $0.text }.joined(separator: " ")
        }
    }
    
    // Helper method to get all image URLs
    public var imageUrls: [String] {
        switch content {
        case .text:
            return []
        case .image(let imageContent):
            return imageContent.url.map { [$0] } ?? []
        case .mixed(let items):
            return items.compactMap { $0.imageUrl?.url }
        }
    }
    
    // Helper method to get all base64 images
    public var base64Images: [String] {
        switch content {
        case .text:
            return []
        case .image(let imageContent):
            return imageContent.base64.map { [$0] } ?? []
        case .mixed(let items):
            return items.compactMap { $0.imageUrl?.base64 }
        }
    }
    
    // Helper method to get all images (URLs and base64)
    public var allImages: [ImageContent] {
        switch content {
        case .text:
            return []
        case .image(let imageContent):
            return [imageContent]
        case .mixed(let items):
            return items.compactMap { $0.imageUrl }
        }
    }
}
