//
//  DataTaskManager.swift
//  Async Image Loading
//
//  Created by Akshay Kumar on 16/04/24.
//

import Foundation

protocol HttpRequestObj {
    var urlString: String { get }
    var page: Int { get }
}

enum RequestError: Error {
    case noInternet
    case decode
    case invalidURL
    case noResponse
    case unauthorized
    case unexpectedStatusCode
    case unknown
}

final class DataTaskManager {
    static let shared = DataTaskManager()

    func dataTask(with reqObj: HttpRequestObj) async throws -> [Item] {
        debugPrint(reqObj)
        if !NetworkMonitor.shared.isConnected {
            throw RequestError.noInternet
        }
        let apiUrl = APIEndpoint.baseUrl + reqObj.urlString
        guard let url = URL(string: apiUrl) else { throw RequestError.invalidURL }
        var request = URLRequest(url: url, timeoutInterval: .infinity)
        request.allHTTPHeaderFields = ["Accept-Version": "v1",
            "Authorization": "Client-ID \(accessKey)"]
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw RequestError.noResponse
            }
            switch response.statusCode {
            case 200, 201:
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode([Item].self, from: data)
            case 401:
                throw RequestError.unauthorized
            default:
                throw RequestError.unexpectedStatusCode
            }
        } catch {
            throw RequestError.decode
        }
    }
}
