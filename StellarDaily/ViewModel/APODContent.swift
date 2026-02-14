//
//  APODContent.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

struct APODContent {
    let apod: APOD
    let media: Media
    let rateLimits: APODRateLimits?
    let isFromCache: Bool
    
    enum Media: Equatable {
        case image(data: Data)
        case video(embedURL: URL, thumbnailData: Data?)
    }
}
