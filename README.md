# StellarDaily

StellarDaily is a small SwiftUI iOS app that uses NASA’s **Astronomy Picture of the Day (APOD)** API ([NASA APOD API](https://github.com/nasa/apod-api)) to display today’s APOD and browse any historical APOD by date. The app supports both **image** and **video** APOD entries and includes a **last-known-good cache** fallback when requests fail.

## Features

### Core
- **Today APOD on launch**: loads date, title, media, and explanation for the current day.
- **Video days supported**: APOD can be an embedded video (e.g. 11 Oct 2021).
- **Browse by date**: user can select any date and load that day’s APOD.
- **Offline / failure fallback**: the **last successful response** (JSON + media bytes) is cached and shown if a subsequent request fails.
- **Tab Bar UI**: separate tabs for *Today* and *Browse*.

### Additional Enhancements
- Works on **iPhone + iPad** and supports multiple orientations.
- **Dark Mode** support (system-driven).
- **Dynamic Type** (system font styles).

## Tech Stack
- SwiftUI
- URLSession (networking)
- WKWebView (video embedding)
- Disk cache (Caches directory) for last-known-good APOD payload + media bytes
- No third-party dependencies

## Architecture
- Lightweight MVVM:
  - `StellarDailyViewModel` drives the UI state (`idle/loading/loaded/error`)
  - `APODService` handles APOD API requests
  - `MediaDownloaderService` downloads image/thumbnail bytes
  - `APODDiskCache` persists last known good JSON + media bytes
- Simple dependency wiring via `AppContainer`

## API Key Setup

By default, the app uses NASA’s `DEMO_KEY` (works out-of-the-box but is rate-limited).

To use your own key:
1. Create a file: `StellarDaily/Configs/Secrets.local.xcconfig`
2. Add: NASA_API_KEY = YOUR_KEY_HERE
3. The project uses optional includes in `Base.xcconfig`:
- `Secrets.xcconfig` (default `DEMO_KEY`)
- `Secrets.local.xcconfig` (local override)

> `Secrets.local.xcconfig` should remain **local only** and must not be committed.

## Build & Run
- Xcode: latest (supports iOS 18)
- Deployment target: iOS 18.0
1. Open `StellarDaily.xcodeproj`
2. Select an iOS 18 simulator (or device)
3. Build & Run

## Tests
- Unit tests: APOD JSON decoding and URL helpers
- UI tests: app launch + tab bar presence/basic navigation

Run:
- `⌘U` in Xcode, or
- Product → Test

## Notes / Edge Cases
- For video APOD entries, the app requests `thumbs=true` so the API may return `thumbnail_url`.
- Cache is stored in the system Caches directory and may be cleared by iOS under storage pressure.

## Screens
- **Today**: loads today’s APOD automatically
- **Browse**: pick a date to load APOD

## License
For internal use.
NASA APOD content is subject to NASA’s and original authors’ usage/copyright terms.

