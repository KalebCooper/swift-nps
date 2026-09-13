# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Swift package foundation for the National Park Service Data API.

## Status

Unreleased scaffolding only. The two product modules, test support, documentation catalogs,
verification scripts, workflows, and demo shell are present. There is no public API yet.
Parks and every other endpoint group, authentication, response models, and request execution
are not yet built. The tests check package wiring and resource loading, not NPS behavior.

NPS destination data does not imply live campsite booking availability or reservation support.
This package provides no freshness, ordering, completeness, or availability guarantees.

## Usage

The modules can be imported; there are no service operations to call yet.

```swift
import SwiftNPSData
import SwiftNPSDataModels
```

## Example

Open `Examples/SwiftNPSDataDemo/SwiftNPSDataDemo.xcodeproj` for an iOS 26 SwiftUI shell.
It links both products through a local package reference and displays the package status.
It makes no network requests and requires no API key. Close the standalone package window
before building the demo to avoid duplicate local-package resolution in Xcode.

## Products

| Product | Status | Dependencies |
| --- | --- | --- |
| `SwiftNPSData` | SDK module foundation; no public API. | `SwiftNPSDataModels`, swifty-networking, swift-http-types. |
| `SwiftNPSDataModels` | Models module foundation; no public API. | None. |

## Requirements

- Swift 6.2 tools and Swift 6 language mode.
- iOS, macOS, tvOS, visionOS, or watchOS 26 and later.
- Linux and Android verification lanes are configured; their results must be verified separately.
- The default trait set is empty. `HTTPPortable` enables the portable transport dependency.

## Installation

No release has been published. For local development, add this checkout as a local Swift package
and select either product. The repository location is
[KalebCooper/swift-nps](https://github.com/KalebCooper/swift-nps).

## License

MIT. See [LICENSE](LICENSE). This project is independent of the National Park Service.
NPS data and media have their own [usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
