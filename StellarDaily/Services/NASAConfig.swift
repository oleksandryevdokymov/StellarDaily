//
//  NASAConfig.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

enum NASAConfig {
    static var apiKey: String {
        if let key = Bundle.main.object(forInfoDictionaryKey: "NASA_API_KEY") as? String {
            return key
        } else {
            return "DEMO_KEY"
        }
    }
}
