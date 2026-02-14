//
//  APODView.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI

struct APODView<ViewModel: StellarDailyViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    let title: String

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle:
                ContentUnavailableView("No Data", systemImage: "photo")

            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .error(let message):
                ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))

            case .loaded(let content):
                APODDetailView(content: content)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
