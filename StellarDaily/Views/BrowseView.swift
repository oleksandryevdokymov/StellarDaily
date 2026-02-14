//
//  BrowseView.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI

struct BrowseView<ViewModel: StellarDailyViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel
    @State private var selectedDate: Date = .now

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                DatePicker(
                    "Select date",
                    selection: $selectedDate,
                    in: ...Date.now,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(.horizontal)

                Button {
                    Task { await viewModel.load(date: selectedDate.apodString) }
                } label: {
                    Text("Load APOD")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)

                Divider()

                APODView(viewModel: viewModel, title: "Browse")
            }
            .navigationTitle("Browse")
        }
    }
}

