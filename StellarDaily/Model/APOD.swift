//
//  APOD.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

struct APOD: Codable, Equatable {
    let date: String            // string in YYYY-MM-DD format from API
    let title: String
    let explanation: String
    let mediaType: MediaType
    let url: String
    let hdurl: String?
    let thumbnailURL: String?   // The URL of thumbnail of the video
    let copyright: String?
    
    enum MediaType: String, Codable {
        case image
        case video
    }
    
    enum CodingKeys: String, CodingKey {
        case date, title, explanation, url, hdurl, copyright
        case mediaType = "media_type"
        case thumbnailURL = "thumbnail_url"
    }
}

extension APOD {
    var urlValue: URL? {
        URL(string: url)
    }

    var thumbnailURLValue: URL? {
        guard let thumbnailURL else { return nil }
        return URL(string: thumbnailURL)
    }
}
