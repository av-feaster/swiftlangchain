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
    @State private var selectedProvider: ProviderType = .openAI
    @State private var tokenCount: Int = 0
    @State private var estimatedCost: Double = 0.0
    @State private var cacheHitRate: Double = 0.0
    
    private let memory = ContextMemory(maxTokens: Config.maxTokens, maxMessages: Config.maxMessages)
    
    enum ProviderType: String, CaseIterable {
        case openAI = "OpenAI"
        case claude = "Claude"
        case gemini = "Gemini"
        case cohere = "Cohere"
    }
    
    var provider: any LLMProvider {
        switch selectedProvider {
        case .openAI:
            return OpenAIProvider(apiKey: Config.openAIAPIKey, model: Config.openAIModel)
        case .claude:
            return AnthropicProvider(apiKey: Config.claudeAPIKey ?? "", model: Config.claudeModel ?? "claude-3-5-sonnet-20241022")
        case .gemini:
            return GeminiProvider(apiKey: Config.geminiAPIKey ?? "", model: Config.geminiModel ?? "gemini-1.5-pro")
        case .cohere:
            return CohereProvider(apiKey: Config.cohereAPIKey ?? "", model: Config.cohereModel ?? "command-r-plus")
        }
    }
    
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
            
            // Provider selection
            Picker("Provider", selection: $selectedProvider) {
                ForEach(ProviderType.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
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
            
            // Token usage display
            HStack {
                VStack(alignment: .leading) {
                    Text("Tokens: \(tokenCount)")
                        .font(.caption)
                    Text("Cost: $\(String(format: "%.4f", estimatedCost))")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                Spacer()
            }
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
                FeatureRow(icon: "waveform", title: "Streaming", description: "Real-time response streaming")
                FeatureRow(icon: "function", title: "Function Calling", description: "OpenAI function calling")
                FeatureRow(icon: "brain", title: "Multiple Providers", description: "OpenAI, Claude, Gemini, Cohere")
                FeatureRow(icon: "iphone", title: "Mobile Tools", description: "Camera, Location, Contacts, Photos")
                FeatureRow(icon: "cylinder", title: "Caching", description: "Response caching for speed")
                FeatureRow(icon: "arrow.clockwise", title: "Retry Logic", description: "Automatic retry with backoff")
                FeatureRow(icon: "speedometer", title: "Rate Limiting", description: "API rate limit management")
                FeatureRow(icon: "chart.bar", title: "Token Counting", description: "Track usage and costs")
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
                
                // Count tokens
                let counter = TokenCounter(model: .gpt4)
                let promptTokens = counter.countTokens(in: userInput)
                let completionTokens = counter.countTokens(in: result)
                let totalTokens = promptTokens + completionTokens
                let cost = counter.estimateCost(tokens: totalTokens, model: .gpt4)
                
                await MainActor.run {
                    response = result
                    tokenCount = totalTokens
                    estimatedCost = cost
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
