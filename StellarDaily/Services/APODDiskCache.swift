//
//  APODDiskCache.swift
//  StellarDaily
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import Foundation

import Foundation

/// Cache API used by APODViewModel.
///
/// Stores:
/// - last successful APOD JSON
/// - last successful media bytes (image for image days, thumbnail for video days if available)
protocol APODDiskCacheProtocol {
    func save(apod: APOD, mediaData: Data?)
    func loadAPOD() -> APOD?
    func loadMediaData() -> Data?
    func clear()
}

/// Simple “last-known-good” disk cache (Caches directory).
///
/// Notes:
/// - Writes are atomic.
/// - If `mediaData` is nil, it removes any previously cached media to avoid mismatches.
final class APODDiskCache: APODDiskCacheProtocol {

    // MARK: - Paths

    private let folderURL: URL
    private let apodJSONURL: URL
    private let mediaURL: URL

    // MARK: - Encoders and Decoders

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    // MARK: - Init

    /// Default uses the app's Caches directory.
    /// You can inject `baseDirectory` in tests (e.g., a temp folder).
    init(cacheFolderName: String = "APODCache",
         baseDirectory: URL? = nil,
         encoder: JSONEncoder = JSONEncoder(),
         decoder: JSONDecoder = JSONDecoder()) {
        let base = baseDirectory ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.folderURL = base.appendingPathComponent(cacheFolderName, isDirectory: true)
        
        self.apodJSONURL = folderURL.appendingPathComponent("last_apod.json")
        self.mediaURL = folderURL.appendingPathComponent("last_media.bin")
        
        self.encoder = encoder
        self.decoder = decoder
        
        createFolderIfNeeded()
    }

    // MARK: - Public

    func save(apod: APOD, mediaData: Data?) {
        createFolderIfNeeded()

        do {
            let jsonData = try encoder.encode(apod)
            try jsonData.write(to: apodJSONURL, options: [.atomic])
        } catch {
            print("Failed to save APOD JSON: \(error)")
        }

        do {
            if let mediaData {
                try mediaData.write(to: mediaURL, options: [.atomic])
            } else {
                // Prevent stale media from being shown for a different APOD
                try? FileManager.default.removeItem(at: mediaURL)
            }
        } catch {
            print("Failed to save media data: \(error)")
        }
    }

    func loadAPOD() -> APOD? {
        guard let data = try? Data(contentsOf: apodJSONURL) else { return nil }
        return try? decoder.decode(APOD.self, from: data)
    }

    func loadMediaData() -> Data? {
        try? Data(contentsOf: mediaURL)
    }

    func clear() {
        try? FileManager.default.removeItem(at: apodJSONURL)
        try? FileManager.default.removeItem(at: mediaURL)
    }

    // MARK: - Private

    private func createFolderIfNeeded() {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: folderURL.path, isDirectory: &isDir), isDir.boolValue {
            return
        }
        try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
    }
}
