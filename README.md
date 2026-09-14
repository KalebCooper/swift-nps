# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Look up parks by code through the National Park Service Data API.

## Status

Unreleased. A parks lookup is available through an everyday client method, a reusable typed
request, and a transport-independent endpoint. All three preserve the NPS collection envelope.
The package includes required API-key configuration, typed responses and errors, and offline
tests backed by recorded NPS responses. Other endpoint groups are not implemented.

NPS destination data does not imply live campsite booking availability or reservation support.
This package provides no freshness, ordering, completeness, or availability guarantees.

## Usage

```swift
import SwiftNPSData
import SwiftNPSDataModels

// Supply your private key at runtime; never put it in source or an application bundle.
let client = try NPSDataClient(apiKey: apiKey)
let code = try ParkCode("acad")
let page = try await client.parks(parkCode: code)
for park in page.data {
  print(park.fullName)
}
```

For a reusable request or a typed endpoint, choose either equivalent call:

```swift
let request = ParkRequest.parks(parkCode: code)
let page = try await client.value(for: request)

let endpoint = Endpoint.parks(parkCode: code)
let samePage = try await client.send(endpoint)
```

Each call sends one GET to `/api/v1/parks?parkCode=acad&limit=1&start=0`. The result is
`ParksResponse`, including string-valued `limit`, `start`, and `total`. An unknown code can
return an empty `data` array. The client does not select a first result, follow pages, retry,
or follow redirects. `ParkCode` accepts 4 to 10 ASCII letters or digits and preserves case.

[Obtain a private NPS API key](https://www.nps.gov/subjects/developer/get-started.htm).
The client sends it in `X-Api-Key`; there is no default key or environment lookup.
Client operations throw `NPSDataError`, preserving recognized gateway errors and their HTTP
metadata, or the underlying transport, decoding, status, or cancellation failure.
NPS rate limits vary; HTTP 429 is returned without automatic retry.

On non-Apple platforms, create `NPSDataClient(configuration:transport:)` with an explicit
`NPSDataConfiguration(apiKey:)` and an HTTPCore transport. Request and endpoint values also
work with a custom executor, including consumer-defined response models through
`ParkRequest.init(endpoint:)`.

## Example

Open `Examples/SwiftNPSDataDemo/SwiftNPSDataDemo.xcodeproj` for an iOS 26 SwiftUI demo.
Enter your API key in the secure field, enter a park code, then tap **Look up park**.
The demo shows loading, results, empty results, and failures. It keeps the key in memory and
does not save it. Close the standalone package window before building the demo to avoid
duplicate local-package resolution in Xcode.

## Products

| Product | Status | Dependencies |
| --- | --- | --- |
| `SwiftNPSData` | Authenticated parks client and typed failures. | `SwiftNPSDataModels`, swifty-networking, swift-http-types. |
| `SwiftNPSDataModels` | Park models, validated codes, requests, and endpoints. | None. |

## Requirements

- Swift 6.2 tools and Swift 6 language mode.
- A private NPS API key for network requests.
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
