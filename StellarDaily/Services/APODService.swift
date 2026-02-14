//
//  APODService.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

protocol APODServiceProtocol {
    func fetchAPOD(date: String?) async throws -> (apod: APOD, rateLimits: APODRateLimits)
}

final class APODService: APODServiceProtocol {
    
    private let apiKey: String
    private let session: URLSession
    
    init(apiKey: String, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    func fetchAPOD(date: String?) async throws -> (apod: APOD, rateLimits: APODRateLimits) {
        guard var components = URLComponents(string: "https://api.nasa.gov/planetary/apod") else {
            throw APODClientError.invalidBaseURL(date: date)
        }
        var items: [URLQueryItem] = [
            .init(name: "api_key", value: apiKey),
            // on video days you get thumbnail_url
            .init(name: "thumbs", value: "true")
        ]
        if let date {
            items.append(.init(name: "date", value: date))
        }
        components.queryItems = items
        
        guard let url = components.url else {
            throw APODClientError.missedBaseURL(date: date)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        let rateLimit = APODRateLimits(
            limit: Int(http.value(forHTTPHeaderField: "X-RateLimit-Limit") ?? ""),
            remaining: Int(http.value(forHTTPHeaderField: "X-RateLimit-Remaining") ?? "")
        )
        
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8)
            throw APODClientError.httpError(statusCode: http.statusCode, body: body)
        }
        
        let apod = try JSONDecoder().decode(APOD.self, from: data)
        return (apod, rateLimit)
    }
}
