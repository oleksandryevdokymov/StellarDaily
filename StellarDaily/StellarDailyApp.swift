//
//  StellarDailyApp.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI

@main
struct StellarDailyApp: App {
    private let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            StellarDailyTabView(container: container)
        }
    }
}
