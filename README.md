# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Find and browse parks through the National Park Service Data API.

## Status

Released as 0.4.0. It covers eleven endpoint groups: alerts, amenities (with its park places and
park visitor centers subgroups), campgrounds, park boundaries, parks, places, road events, things
to do, tours, visitor centers, and webcams. CHANGELOG lists what each release added.

Every offset-paginated group shares one collection core: a validated query, the `NPSCollection`
envelope, reusable typed requests, and transport-independent endpoints. Each group is available as
a lazy page sequence, a lazy item sequence, or a single page, and pagination uses
swifty-networking 1.1.0.

Alerts queries support park codes, state codes, text search, and pagination through `alertPages`
and `alerts`; NPS documents no alerts sorting. Amenities queries support identifiers and text
search through `amenityPages` and `amenities`; NPS documents no park, state, or sort parameter
there. Amenity park places and park visitor centers queries support identifiers, park codes, text
search, and sorting; their pages keep the provider's per-amenity groups, and
`amenityParkPlaces` and `amenityParkVisitorCenters` yield each entry. Campgrounds queries support
park codes, state codes, text search, and sorting through `campgroundPages` and `campgrounds`;
published site counts and fees are not live availability. Parks queries support park codes, state
codes, text search, and sorting through `parkPages` and `parks`, and the single park code lookup
keeps its own exact request and response. Places queries support park codes, state codes, and text
search through `placePages` and `places`; the endpoint answers every sort value with HTTP 400, so
the query offers none. Things to do queries support identifiers, park codes, state codes, text
search, and sorting through `thingToDoPages` and `thingsToDo`; NPS documents only `relevanceScore`
as a sort field and answers others with HTTP 400. Tours queries support identifiers, park codes,
state codes, text search, and sorting through `tourPages` and `tours`; `relevanceScore` is again
the only sort field the live service accepts, each tour links one park, and durations and stop
ordinals stay provider text. Visitor centers queries support park codes, state codes, text search,
and sorting through `visitorCenterPages` and `visitorCenters`. Webcams queries support identifiers,
park codes, state codes, and text search through `webcamPages` and `webcams`; the endpoint answers
every sort value with HTTP 400, the streaming flag stays a Boolean, and coordinates stay numbers or
null and are not guaranteed to locate the camera.

Two groups return one complete response rather than a collection. `parkBoundary` returns one park's
GeoJSON boundary, usually a `MultiPolygon`, with coordinates kept as sent. `roadEvents` returns one
WZDx 4.1 feed, optionally narrowed to one park code and one event type; most parks return an empty
feed, and an unrecognized park code returns every park's events.

The package includes required API-key configuration, typed failures, and recorded-response tests.
The events endpoint group is not implemented.

NPS destination data does not imply live campsite booking availability or reservation support.
This package provides no freshness, ordering, completeness, or availability guarantees.

## Usage

Every NPS collection in this package is available at three equivalent levels: an everyday client
method, a reusable `NPSDataRequest`, and a typed `Endpoint` for one page. Parks work as the example
below; every other implemented collection follows the same three levels. A validated `ParkQuery`
drives all three:

```swift
import SwiftNPSData
import SwiftNPSDataModels

// Supply your private key at runtime; never put it in source or an application bundle.
let client = try NPSDataClient(apiKey: apiKey)
let query = try ParkQuery(
  limit: 20, searchText: "history", sort: [.descending("relevanceScore")],
  stateCodes: [StateCode("ME"), StateCode("MA")])

// Everyday methods: lazy pages or individual parks.
for try await page in client.parkPages(query: query) {
  print("Received \(page.data.count) of \(page.total) parks")
}
for try await park in client.parks(query: query) {
  print(park.fullName)
}

// A reusable, inspectable request: pages, items, or just the first page.
let request = NPSDataRequest.parks(query: query)
let pages = client.pages(for: request)
let parks = client.items(for: request)
let onePage = try await client.value(for: request)

// A typed endpoint for one page.
let samePage = try await client.send(.parks(query: query))
```

Each page is `NPSCollection<Park>`, including string-valued `limit`, `start`, and `total` and the
provider's result order. The parks conveniences delegate to the generic `pages(for:)` and
`items(for:)`, so every level shares request construction, authentication, and typed failures.

`ParkQuery` explicitly defaults to `limit=50` and `start=0`, with both overridable. Code filters
preserve caller order and case. Empty filter arrays omit the filter; empty sorting uses NPS's
full-name default. Search text is encoded without trimming. Sort by full name, park code, or
relevance in either direction; relevance cannot be combined with other sort criteria.

Each loop starts its own traversal. Construction sends nothing. Pages fetch on demand; individual
items drain the current page before fetching another. Breaking a loop prevents later requests.
Pagination advances by the returned item count and stops when that range reaches the reported
total. Empty pages terminate only at or beyond the total. Invalid numeric metadata, an unexpected
offset, contradictory counts, or overflow throws `NPSDataError.pagination` before yielding the
affected page. Earlier results do not imply completion. Results can change between requests;
the sequences do not deduplicate or promise a stable snapshot.

To look up one park code, use any of the same three levels:

```swift
let code = try ParkCode("acad")
let page = try await client.parks(parkCode: code)
let samePage = try await client.value(for: .parks(parkCode: code))
let anotherPage = try await client.send(.parks(parkCode: code))
```

Each call sends one GET to `/api/v1/parks?parkCode=acad&limit=1&start=0` and declares no
continuation. An unknown code can return an empty `data` array. The client does not select a
first result, follow pages, retry, or follow redirects. `ParkCode` accepts 4 to 10 ASCII letters
or digits and preserves case. A request created with `init(endpoint:)` also yields one page.

[Obtain a private NPS API key](https://www.nps.gov/subjects/developer/get-started.htm).
The client sends it in `X-Api-Key`; there is no default key or environment lookup.
Client operations throw `NPSDataError`, preserving recognized gateway errors and their HTTP
metadata, or the underlying transport, decoding, status, or cancellation failure.
NPS rate limits vary; HTTP 429 is returned without automatic retry.

On non-Apple platforms, create `NPSDataClient(configuration:transport:)` with an explicit
`NPSDataConfiguration(apiKey:)` and an HTTPCore transport. Request and endpoint values also
work with a custom executor, which sends `NPSCollectionResolution.endpoint` and continues with
`next(after:)`, including consumer-defined response models through `NPSDataRequest.init(endpoint:)`.

## Example

Open `Examples/SwiftNPSDataDemo/SwiftNPSDataDemo.xcodeproj` for an iOS 26 SwiftUI demo.
Choose a group, enter your API key, then tap the group's **Search** button. Collection groups take
park and state codes and search text, except amenities, which takes search text alone; road events
takes one optional park code and an optional event type, and park boundaries takes one park code.
Use **Load more** to request the next page of a collection group or **Cancel** to stop an in-flight
request; road events and park boundaries arrive as one response.
The demo shows loading, results, empty results, and failures. It keeps the key in memory and
does not save it. Close the standalone package window before building the demo to avoid
duplicate local-package resolution in Xcode.

## Products

| Product | Status | Dependencies |
| --- | --- | --- |
| `SwiftNPSData` | Authenticated collection execution, lazy page and item sequences, alerts, amenities, campgrounds, park boundaries, parks, places, road events, things to do, tours, visitor centers, and webcams conveniences, typed failures. | `SwiftNPSDataModels`, swifty-networking, swift-http-types. |
| `SwiftNPSDataModels` | Generic collection envelope, queries, continuation rules, requests, and endpoints; alert, amenity, campground, park boundary, park, place, road event, thing to do, tour, visitor center, webcam, and shared detail models. | None. |

## Requirements

- Swift 6.2 tools and Swift 6 language mode.
- A private NPS API key for network requests.
- iOS, macOS, tvOS, visionOS, or watchOS 26 and later.
- Linux and Android verification lanes are configured; their results must be verified separately.
- The default trait set is empty. `HTTPPortable` enables the portable transport dependency.

## Installation

Add the package dependency and select either product:

```swift
.package(url: "https://github.com/KalebCooper/swift-nps.git", from: "0.4.0")
```

The repository is [KalebCooper/swift-nps](https://github.com/KalebCooper/swift-nps).

## License

MIT. See [LICENSE](LICENSE). This project is independent of the National Park Service.
NPS data and media have their own [usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
