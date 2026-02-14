//
//  APODClientError.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

enum APODClientError: LocalizedError {
    case invalidBaseURL(date: String?)
    case missedBaseURL(date: String?)
    case invalidMediaURL(String)
    case httpError(statusCode: Int, body: String?)

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL(let date):
            return "Invalid base URL for APOD. Date: \(date ?? "nil")"
        case .missedBaseURL(let date):
            return "Missing base URL for APOD. Date: \(date ?? "nil")"
        case .invalidMediaURL(let value):
            return "Invalid media URL: \(value)"
        case .httpError(let statusCode, let body):
            return "HTTP error. Status code: \(statusCode). Body: \(body ?? "nil")"
        }
    }
}
