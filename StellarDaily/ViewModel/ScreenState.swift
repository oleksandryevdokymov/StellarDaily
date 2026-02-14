//
//  ScreenState.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

enum ScreenState {
    case idle
    case loading
    case loaded(APODContent)
    case error(String)
}
