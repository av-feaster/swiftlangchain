import Foundation

public struct ImageUtils {

    /// Convert Data to base64 string
    public static func dataToBase64(_ data: Data) -> String {
        return data.base64EncodedString()
    }

    /// Convert base64 string to Data
    public static func base64ToData(_ base64String: String) -> Data? {
        return Data(base64Encoded: base64String)
    }

    /// Load image data from URL and return base64 string (via completion)
    public static func urlToBase64(_ url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        fetchData(from: url) { result in
            switch result {
            case .success(let data):
                let base64 = data.base64EncodedString()
                completion(.success(base64))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Load image data from URL string and return base64 string (via completion)
    public static func urlStringToBase64(_ urlString: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageError.invalidURL))
            return
        }
        urlToBase64(url, completion: completion)
    }

    /// Fetch data from a remote URL (compatible with older platforms)
    public static func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(ImageError.invalidImageData))
            }
        }.resume()
    }
}

public enum ImageError: Error, LocalizedError {
    case invalidURL
    case invalidImageData

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .invalidImageData:
            return "Invalid image data"
        }
    }
}
