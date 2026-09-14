# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Find and browse parks through the National Park Service Data API.

## Status

Released as 0.1.0; the following parks expansion is unreleased. Parks queries support multiple park
codes, state codes, text search, sorting, and pagination. Lazy `parkPages` and `parks` sequences
provide complete pages or individual parks using swifty-networking 1.1.0. Reusable typed requests
and transport-independent endpoints remain available for single-page execution. The package
includes required API-key configuration, typed failures, and recorded-response tests.
Other endpoint groups are not implemented.

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

For a filtered search, use the same query with either lazy sequence:

```swift
let query = try ParkQuery(
  limit: 20, searchText: "history", sort: [.relevanceScore(.descending)],
  stateCodes: [StateCode("ME"), StateCode("MA")])

for try await page in client.parkPages(query: query) {
  print("Received \(page.data.count) of \(page.total) parks")
}

for try await park in client.parks(query: query) {
  print(park.fullName)
}
```

Each loop above starts its own traversal. Construction sends nothing. Pages fetch on demand;
individual parks drain the current page before fetching another. Breaking a loop prevents later
requests. `ParkQuery` explicitly defaults to `limit=50` and `start=0`, with both overridable.
Code filters preserve caller order and case. Empty filter arrays omit the filter; empty sorting
uses NPS's full-name default. Search text is encoded without trimming. Sort by full name, park code,
or relevance in either direction; relevance cannot be combined with other sort criteria.

Reuse an inspectable query request for pages, parks, or just one page:

```swift
let request = ParkRequest.parks(query: query)
let pages = client.parkPages(for: request)
let parks = client.parks(for: request)
let onePage = try await client.value(for: request)
let samePage = try await client.send(.parks(query: query))
```

Pagination advances by the returned item count and stops when that range reaches the reported
total. Empty pages terminate only at or beyond the total. Invalid numeric metadata, an unexpected
offset, contradictory counts, or overflow throws `NPSDataError.pagination` before yielding the
affected page. Earlier results do not imply completion. Results can change between requests;
the sequences do not deduplicate or promise a stable snapshot. A request created with
`init(endpoint:)`, or the legacy single-code factory, declares no continuation and yields one page.

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
| `SwiftNPSData` | Authenticated parks queries, lazy page and park sequences, typed failures. | `SwiftNPSDataModels`, swifty-networking, swift-http-types. |
| `SwiftNPSDataModels` | Park models, validated queries, continuation rules, requests, and endpoints. | None. |

## Requirements

- Swift 6.2 tools and Swift 6 language mode.
- A private NPS API key for network requests.
- iOS, macOS, tvOS, visionOS, or watchOS 26 and later.
- Linux and Android verification lanes are configured; their results must be verified separately.
- The default trait set is empty. `HTTPPortable` enables the portable transport dependency.

## Installation

Add the package dependency and select either product:

```swift
.package(url: "https://github.com/KalebCooper/swift-nps.git", from: "0.1.0")
```

The repository is [KalebCooper/swift-nps](https://github.com/KalebCooper/swift-nps).

## License

MIT. See [LICENSE](LICENSE). This project is independent of the National Park Service.
NPS data and media have their own [usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
