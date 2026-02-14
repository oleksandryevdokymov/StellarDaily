//
//  AppContainer.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

final class AppContainer {
    private let cache = APODDiskCache()
    private let mediaDownloader: MediaDownloaderServiceProtocol = MediaDownloaderService()

    private lazy var service: APODServiceProtocol = {
        APODService(apiKey: NASAConfig.apiKey)
    }()

    func makeTodayViewModel() -> StellarDailyViewModel {
        StellarDailyViewModel(service: service, mediaDownloader: mediaDownloader, cache: cache)
    }

    func makeBrowseViewModel() -> StellarDailyViewModel {
        StellarDailyViewModel(service: service, mediaDownloader: mediaDownloader, cache: cache)
    }
}
