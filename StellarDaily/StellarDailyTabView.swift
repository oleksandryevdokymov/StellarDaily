//
//  StellarDailyTabView.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI

struct StellarDailyTabView: View {

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
    }

    var body: some View {
        TabView {
            TodayView(viewModel: container.makeTodayViewModel())
                .tabItem { Label("Today", systemImage: "sparkles") }

            BrowseView(viewModel: container.makeBrowseViewModel())
                .tabItem { Label("Browse", systemImage: "calendar") }
        }
    }
}

