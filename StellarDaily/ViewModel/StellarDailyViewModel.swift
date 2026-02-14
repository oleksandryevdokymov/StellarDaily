//
//  StellarDailyViewModel.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation
import SwiftUI
import Combine

protocol StellarDailyViewModelProtocol: ObservableObject {
    var state: ScreenState { get }
    func load(date: String?) async
}

@MainActor
final class StellarDailyViewModel: StellarDailyViewModelProtocol {

    // MARK: - State

    @Published private(set) var state: ScreenState = .idle

    // MARK: - Dependencies

    private let service: APODServiceProtocol
    private let mediaDownloader: MediaDownloaderServiceProtocol
    private let cache: APODDiskCache

    // MARK: - Initialization and Lyfe Cycle
    
    init(service: APODServiceProtocol,
         mediaDownloader: MediaDownloaderServiceProtocol,
         cache: APODDiskCache) {
        self.service = service
        self.mediaDownloader = mediaDownloader
        self.cache = cache
    }

    // MARK: - Public API

    /// Loads APOD for a specific date (YYYY-MM-DD) or `nil` for today.
    func load(date: String?) async {
        state = .loading

        do {
            let content = try await loadFromNetwork(date: date)
            state = .loaded(content)
        } catch {
            if let cached = loadFromCache() {
                state = .loaded(cached)
            } else {
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Network path

    private func loadFromNetwork(date: String?) async throws -> APODContent {
        let result = try await service.fetchAPOD(date: date)
        let apod = result.apod

        let media = try await buildMediaForNetwork(apod: apod)
        cacheContent(apod: apod, media: media)

        return APODContent(
            apod: apod,
            media: media,
            rateLimits: result.rateLimits,
            isFromCache: false
        )
    }

    private func buildMediaForNetwork(apod: APOD) async throws -> APODContent.Media {
        guard let urlValue = apod.urlValue else {
            throw APODClientError.invalidMediaURL(apod.url)
        }
        
        switch apod.mediaType {
        case .image:
            let data = try await mediaDownloader.downloadData(from: urlValue)
            return .image(data: data)

        case .video:
            let thumbData: Data?
            if let thumbURL = apod.thumbnailURLValue {
                thumbData = try? await mediaDownloader.downloadData(from: thumbURL)
            } else {
                thumbData = nil
            }
            return .video(embedURL: urlValue, thumbnailData: thumbData)
        }
    }

    private func cacheContent(apod: APOD, media: APODContent.Media) {
        // Requirement: cache last successful call INCLUDING image.
        // For videos we cache thumbnail if available.
        let mediaData: Data? = {
            switch media {
            case .image(let data): return data
            case .video(_, let thumbData): return thumbData
            }
        }()

        cache.save(apod: apod, mediaData: mediaData)
    }

    // MARK: - Cache fallback path

    private func loadFromCache() -> APODContent? {
        guard let apod = cache.loadAPOD() else { return nil }
        let cachedMediaData = cache.loadMediaData()

        let media: APODContent.Media
        switch apod.mediaType {
        case .image:
            media = .image(data: cachedMediaData ?? Data())

        case .video:
            guard let embedURL = apod.urlValue else {
                // cached APOD has an invalid URL string -> no valid fallback
                return nil
            }
            media = .video(embedURL: embedURL, thumbnailData: cachedMediaData)
        }

        return APODContent(apod: apod,
                           media: media,
                           rateLimits: nil,
                           isFromCache: true)
    }
}
