//
//  APODDetailView.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import SwiftUI

struct APODDetailView: View {
    let content: APODContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                if content.isFromCache {
                    Text("Loaded from cache")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(content.apod.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)

                Text(content.apod.date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                mediaView

                Text(content.apod.explanation)
                    .font(.body)
                    .textSelection(.enabled)

                if let copyright = content.apod.copyright {
                    Text("© \(copyright)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let rate = content.rateLimits {
                    rateLimitsView(rate)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var mediaView: some View {
        switch content.media {
        case .image(let data):
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                ContentUnavailableView("Image unavailable", systemImage: "photo")
            }

        case .video(let embedURL, let thumbData):
            VStack(alignment: .leading, spacing: 8) {
                if let thumbData, let uiImage = UIImage(data: thumbData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                if UIDevice.isPad {
                    VideoEmbedView(url: embedURL)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(16/9, contentMode: .fit)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    VideoEmbedView(url: embedURL)
                        .frame(minHeight: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }

    @ViewBuilder
    private func rateLimitsView(_ rate: APODRateLimits) -> some View {
        // Adjust field names to match your APODRateLimits model
        VStack(alignment: .leading, spacing: 4) {
            Text("Rate limits")
                .font(.headline)

            if let limit = rate.limit {
                Text("Limit: \(limit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let remaining = rate.remaining {
                Text("Remaining: \(remaining)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }
}
