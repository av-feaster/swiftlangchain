//
//  NetworkClient.swift
//  swiftlangchain
//
//  Created by Aman Verma on 28/07/25.
//

import Foundation
import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case httpError(Int, Data)
    case decodingError(Error)
}

public struct NetworkClient {
    
    public static func post<T: Decodable>(
        url: URL,
        headers: [String: String],
        body: [String: Any],
        responseType: T.Type,
        completion: @escaping @Sendable (Result<T, NetworkError>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(.requestFailed(error)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(.httpError(httpResponse.statusCode, data)))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
    
    
  
    // **MARK: - Async/await version for modern Swift**
    private struct UncheckedSendableResult<T>: @unchecked Sendable {
        let result: Result<T, NetworkError>
    }

    // Then use it like this:
    public static func postUnsafe<T: Decodable>(
        url: URL,
        headers: [String: String],
        body: [String: Any],
        responseType: T.Type
    ) async throws -> T {
        if #available(iOS 13.0, macOS 10.15, *) {
            return try await withCheckedThrowingContinuation { continuation in
                post(url: url, headers: headers, body: body, responseType: responseType) { result in
                    let sendableResult = UncheckedSendableResult(result: result)
                    continuation.resume(with: sendableResult.result)
                }
            }
        } else {
            throw NetworkError.requestFailed(
                NSError(
                    domain: "NetworkClient",
                    code: -1000,
                    userInfo: [NSLocalizedDescriptionKey: "Async/await is not supported on this OS version."]
                )
            )
        }
    }


}
