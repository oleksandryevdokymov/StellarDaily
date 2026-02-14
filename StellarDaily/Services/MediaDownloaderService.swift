//
//  MediaDownloaderService.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

protocol MediaDownloaderServiceProtocol {
    func downloadData(from url: URL) async throws -> Data
}

final class MediaDownloaderService: MediaDownloaderServiceProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func downloadData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
