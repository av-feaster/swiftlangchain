//
//  SearchTool.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//


// MARK: - Concrete Tool Implementations
/// Search tool implementation using Tavily API
public struct SearchTool: Tool, Sendable {
    public let name = "search"
    public let description = "Searches the web for information using Tavily search API. Returns search results with titles, snippets, and URLs."
    
    private let apiKey: String
    private let baseURL: String
    
    public init(apiKey: String, baseURL: String = "https://api.tavily.com/search") {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    public func syncExecute(_ input: String) throws -> String {
        // For sync execution, we'll use a blocking wait on the async call
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<String, Error>?
        
        Task {
            do {
                let output = try await execute(input)
                result = .success(output)
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        
        switch result {
        case .success(let output):
            return output
        case .failure(let error):
            throw error
        case .none:
            throw ToolError.executionFailed("Search failed with unknown error")
        }
    }
    
    public func execute(_ input: String) async throws -> String {
        guard let url = URL(string: baseURL) else {
            throw ToolError.executionFailed("Invalid Tavily API URL")
        }
        
        let requestBody: [String: Any] = [
            "api_key": apiKey,
            "query": input,
            "search_depth": "basic",
            "max_results": 10,
            "include_answer": false,
            "include_raw_content": false
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ToolError.executionFailed("Invalid response from Tavily API")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = errorJson["detail"] as? String {
                throw ToolError.executionFailed("Tavily API error: \(errorMessage)")
            }
            throw ToolError.executionFailed("Tavily API returned status code: \(httpResponse.statusCode)")
        }
        
        guard let searchResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = searchResponse["results"] as? [[String: Any]] else {
            throw ToolError.executionFailed("Failed to parse Tavily API response")
        }
        
        // Format search results for LLM consumption
        var formattedResults = "Search Results for: \(input)\n\n"
        
        for (index, result) in results.enumerated() {
            if let title = result["title"] as? String,
               let url = result["url"] as? String,
               let snippet = result["content"] as? String {
                formattedResults += "\(index + 1). \(title)\n"
                formattedResults += "   URL: \(url)\n"
                formattedResults += "   Snippet: \(snippet)\n\n"
            }
        }
        
        return formattedResults
    }
}

/// Weather tool implementation
public final class WeatherTool: Tool {
    public let name = "weather"
    public let description = "Gets weather information for a location"

    public init() {}

    public func syncExecute(_ input: String) throws -> String {
        // Simplified implementation for now
        return "Weather for: \(input)"
    }
}

/// Database query tool implementation
public final class DatabaseTool: Tool {
    public let name = "database"
    public let description = "Executes database queries"

    public init() {}

    public func syncExecute(_ input: String) throws -> String {
        // Simplified implementation for now
        return "Database query result for: \(input)"
    }
}
