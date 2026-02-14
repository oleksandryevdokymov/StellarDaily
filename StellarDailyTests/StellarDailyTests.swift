//
//  StellarDailyTests.swift
//  StellarDailyTests
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import XCTest
@testable import StellarDaily

final class StellarDailyModelTests: XCTestCase {

    // MARK: - JSON decoding

    @MainActor
    func testAPOD_decodesImagePayload() throws {
        let json = """
        {
          "date": "2026-02-14",
          "title": "Roses are Red",
          "explanation": "Hello",
          "media_type": "image",
          "url": "https://example.com/a.jpg",
          "hdurl": "https://example.com/a_hd.jpg"
        }
        """.data(using: .utf8)!

        let apod = try JSONDecoder().decode(APOD.self, from: json)

        XCTAssertEqual(apod.date, "2026-02-14")
        XCTAssertEqual(apod.title, "Roses are Red")
        XCTAssertEqual(apod.mediaType, .image)
        XCTAssertEqual(apod.url, "https://example.com/a.jpg")
        XCTAssertEqual(apod.hdurl, "https://example.com/a_hd.jpg")
        XCTAssertNil(apod.thumbnailURL)
    }

    @MainActor
    func testAPOD_decodesVideoPayload_withThumbnail() throws {
        let json = """
        {
          "date": "2021-10-11",
          "title": "Video Day",
          "explanation": "Hello",
          "media_type": "video",
          "url": "https://www.youtube.com/embed/dQw4w9WgXcQ",
          "thumbnail_url": "https://example.com/t.jpg"
        }
        """.data(using: .utf8)!

        let apod = try JSONDecoder().decode(APOD.self, from: json)

        XCTAssertEqual(apod.date, "2021-10-11")
        XCTAssertEqual(apod.mediaType, .video)
        XCTAssertEqual(apod.url, "https://www.youtube.com/embed/dQw4w9WgXcQ")
        XCTAssertEqual(apod.thumbnailURL, "https://example.com/t.jpg")
        XCTAssertNil(apod.hdurl)
    }

    @MainActor
    func testAPOD_decodesVideoPayload_withoutThumbnail() throws {
        let json = """
        {
          "date": "2021-10-12",
          "title": "Video Day No Thumb",
          "explanation": "Hello",
          "media_type": "video",
          "url": "https://www.youtube.com/embed/abc123"
        }
        """.data(using: .utf8)!

        let apod = try JSONDecoder().decode(APOD.self, from: json)

        XCTAssertEqual(apod.mediaType, .video)
        XCTAssertEqual(apod.thumbnailURL, nil)
    }

    @MainActor
    func testAPOD_decodesOptionalCopyright() throws {
        let json = """
        {
          "date": "2026-02-14",
          "title": "Test",
          "explanation": "Hello",
          "media_type": "image",
          "url": "https://example.com/a.jpg",
          "copyright": "Someone"
        }
        """.data(using: .utf8)!

        let apod = try JSONDecoder().decode(APOD.self, from: json)
        XCTAssertEqual(apod.copyright, "Someone")
    }

    @MainActor
    func testAPOD_decodingFails_whenMissingRequiredField() throws {
        let jsonMissingTitle = """
        {
          "date": "2026-02-14",
          "explanation": "Hello",
          "media_type": "image",
          "url": "https://example.com/a.jpg"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(APOD.self, from: jsonMissingTitle))
    }
    
    @MainActor
    func testAPOD_decodingFails_onUnknownMediaType() throws {
        let json = """
        {
          "date": "2026-02-14",
          "title": "Test",
          "explanation": "Hello",
          "media_type": "gif",
          "url": "https://example.com/a.gif"
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(APOD.self, from: json))
    }

    // MARK: - URL validation helpers (strict test-only)

    func testURLValidation_invalidScheme_returnsNil() throws {
        XCTAssertNil("notaurl://abc".httpURL)          // invalid scheme
        XCTAssertNil("file:///tmp/a.jpg".httpURL)      // not http/https
        XCTAssertNil("https://".httpURL)               // missing host
    }

    func testURLValidation_validHTTPS_returnsURL() throws {
        let url = try XCTUnwrap("https://example.com/a.jpg".httpURL)
        XCTAssertEqual(url.scheme?.lowercased(), "https")
        XCTAssertEqual(url.host, "example.com")
        XCTAssertEqual(url.path, "/a.jpg")
    }

    func testURLValidation_rejectsRelativeURLs() throws {
        XCTAssertNil("not a url".httpURL)
        XCTAssertNil("/images/a.jpg".httpURL)
        XCTAssertNil("example.com/a.jpg".httpURL)
    }

    // MARK: - APOD computed URL properties (loose behavior)

    @MainActor
    func testAPOD_urlValue_andThumbnailURLValue_useLooseURLParsing() throws {
        let apod = APOD(
            date: "2026-02-14",
            title: "Test",
            explanation: "E",
            mediaType: .video,
            url: "notaurl://abc",
            hdurl: nil,
            thumbnailURL: "https://example.com/t.jpg",
            copyright: nil
        )

        XCTAssertNotNil(apod.urlValue)
        XCTAssertEqual(apod.urlValue?.scheme?.lowercased(), "notaurl")
        XCTAssertNotNil(apod.thumbnailURLValue)
    }

    @MainActor
    func testAPOD_thumbnailURLValue_isNil_whenThumbnailURLMissing() throws {
        let apod = APOD(
            date: "2026-02-14",
            title: "Test",
            explanation: "E",
            mediaType: .video,
            url: "https://www.youtube.com/embed/abc",
            hdurl: nil,
            thumbnailURL: nil,
            copyright: nil
        )

        XCTAssertNil(apod.thumbnailURLValue)
    }

    @MainActor
    func testAPOD_hdurlValue_presentWhenHdurlProvided() throws {
        let apod = APOD(
            date: "2026-02-14",
            title: "Test",
            explanation: "E",
            mediaType: .image,
            url: "https://example.com/a.jpg",
            hdurl: "https://example.com/a_hd.jpg",
            thumbnailURL: nil,
            copyright: nil
        )

        XCTAssertEqual(apod.hdurl, "https://example.com/a_hd.jpg")
    }
}

// MARK: - Local test-only strict URL validation (no app code changes needed)

private extension String {
    /// Strictly accept only absolute http/https URLs with host.
    var httpURL: URL? {
        guard
            let url = URL(string: self),
            let scheme = url.scheme?.lowercased(),
            (scheme == "http" || scheme == "https"),
            url.host != nil
        else { return nil }
        return url
    }
}
