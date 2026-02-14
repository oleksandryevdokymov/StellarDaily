//
//  TodayView.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI

struct TodayView<ViewModel: StellarDailyViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            APODView(viewModel: viewModel, title: "Today")
                .task { await viewModel.load(date: nil) }
        }
    }
}
