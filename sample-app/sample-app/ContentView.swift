//
//  ContentView.swift
//  sample-app
//
//  Created by Aman Verma on 22/04/26.
//

import SwiftUI
import SwiftLangChain

struct ContentView: View {
    @State private var userInput = ""
    @State private var response = ""
    @State private var isLoading = false
    
    // Initialize components using Config
    private let provider = OpenAIProvider(apiKey: Config.openAIAPIKey, model: Config.openAIModel)
    private let memory = ContextMemory(maxTokens: Config.maxTokens, maxMessages: Config.maxMessages)
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 50))
            
            Text("SwiftLangChain Demo")
                .font(.title)
                .fontWeight(.bold)
            
            Text("AI-powered conversational interface")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            // Response display
            ScrollView {
                Text(response.isEmpty ? "Response will appear here..." : response)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .frame(height: 200)
            
            // Input field
            TextField("Enter your message...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Send button
            Button(action: sendMessage) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text(isLoading ? "Sending..." : "Send")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(userInput.isEmpty || isLoading)
            .padding(.horizontal)
            
            Divider()
            
            // Feature showcase
            VStack(alignment: .leading, spacing: 10) {
                Text("Available Features:")
                    .font(.headline)
                
                FeatureRow(icon: "message.fill", title: "Conversation Memory", description: "Maintains chat history")
                FeatureRow(icon: "link", title: "Chain Composition", description: "Chain multiple operations")
                FeatureRow(icon: "wrench.and.screwdriver", title: "Tool Support", description: "Use tools like Calculator")
                FeatureRow(icon: "photo", title: "Image Support", description: "Analyze images with GPT-4 Vision")
            }
            .padding()
        }
        .padding()
    }
    
    private func sendMessage() {
        isLoading = true
        
        Task {
            do {
                let chain = ConversationChain(llm: provider, memory: memory)
                let result = try await chain.run(userInput)
                
                await MainActor.run {
                    response = result
                    userInput = ""
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    response = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
