# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Find and browse parks through the National Park Service Data API.

## Status

Released as 0.4.0, which covers eleven endpoint groups: alerts, amenities (with its park places
and park visitor centers subgroups), campgrounds, park boundaries, parks, places, road events,
things to do, tours, visitor centers, and webcams. Articles, news releases, park audio, park
videos, people, photo galleries, and photo gallery assets are built and not yet released.
CHANGELOG lists what each release added.

Every offset-paginated group shares one collection core: a validated query, the `NPSCollection`
envelope, reusable typed requests, and transport-independent endpoints. Each group is available as
a lazy page sequence, a lazy item sequence, or a single page, and pagination uses
swifty-networking 1.1.0. Two groups, park boundaries and road events, return one complete response
rather than a collection.

| Group | Filters and sort | Methods | Notes |
| --- | --- | --- | --- |
| Alerts | Park codes, state codes, text search. NPS documents no sort. | `alertPages`, `alerts` | |
| Amenities | Identifiers, text search. NPS documents no park, state, or sort parameter. | `amenityPages`, `amenities` | |
| Amenity park places | Identifiers, park codes, text search, sorting. | `amenityParkPlacePages`, `amenityParkPlaces` | Pages keep the provider's per-amenity groups; `amenityParkPlaces` yields each entry. |
| Amenity park visitor centers | Identifiers, park codes, text search, sorting. | `amenityParkVisitorCenterPages`, `amenityParkVisitorCenters` | Pages keep the provider's per-amenity groups; `amenityParkVisitorCenters` yields each entry. |
| Articles | Park codes, state codes, text search. | `articlePages`, `articles` | The endpoint answers `sort=title` with HTTP 400, so the query offers no sort; coordinates stay numbers or null and most articles send none. |
| Campgrounds | Park codes, state codes, text search, sorting. | `campgroundPages`, `campgrounds` | Published site counts and fees are not live availability. |
| News releases | Park codes, state codes, text search, sorting. | `newsReleasePages`, `newsReleases` | The live service sorts by `releaseDate` and `title` and answers other fields with HTTP 400; release timestamps stay the provider's text without a time zone. |
| Park audio | Park codes, state codes, text search, sorting. | `parkAudioPages`, `parkAudio` | The live service sorts by `title` and answers other fields with HTTP 400; transcripts stay plain text or HTML, and file sizes keep the provider's number, for which NPS documents no unit. |
| Park videos | Park codes, state codes, text search, sorting. | `parkVideoPages`, `parkVideos` | The live service sorts by `title` and answers other fields with HTTP 400; accessibility flags stay Booleans, and file sizes keep the provider's number or null, for which NPS documents no unit. |
| Parks | Park codes, state codes, text search, sorting. | `parkPages`, `parks` | The single park code lookup (`parks(parkCode:)`) keeps its own exact request and response. |
| People | Park codes, state codes, text search. | `personPages`, `people` | The endpoint answers `sort=title` and `sort=lastName` with HTTP 400, so the query offers no sort; coordinates stay the provider's text, usually empty, and profiles stay HTML. |
| Photo galleries | Park codes, state codes, text search, sorting. | `photoGalleryPages`, `photoGalleries` | The live service sorts by `title` and answers other fields with HTTP 400; each gallery carries one preview image and the provider's asset count, and rights constraints stay open text. |
| Photo gallery assets | Gallery identifiers, identifiers, park codes, state codes, text search, sorting. | `photoGalleryAssetPages`, `photoGalleryAssets` | The live service sorts by `title` and answers other fields with HTTP 400; a gallery or asset identifier that is not UUID-shaped is ignored and every asset comes back, an asset in several galleries appears once per gallery, and file sizes keep the provider's number, for which NPS documents no unit. |
| Places | Park codes, state codes, text search. | `placePages`, `places` | The endpoint answers every sort value with HTTP 400, so the query offers none. |
| Things to do | Identifiers, park codes, state codes, text search, sorting. | `thingToDoPages`, `thingsToDo` | NPS documents only `relevanceScore` as a sort field and answers others with HTTP 400. |
| Tours | Identifiers, park codes, state codes, text search, sorting. | `tourPages`, `tours` | `relevanceScore` is the only sort field the live service accepts; each tour links one park; durations and stop ordinals stay provider text. |
| Visitor centers | Park codes, state codes, text search, sorting. | `visitorCenterPages`, `visitorCenters` | |
| Webcams | Identifiers, park codes, state codes, text search. | `webcamPages`, `webcams` | The endpoint answers every sort value with HTTP 400; the streaming flag stays a Boolean; coordinates stay numbers or null and are not guaranteed to locate the camera. |
| Park boundaries | One park code, as a path segment; no query parameters. | `parkBoundary` | One complete response, no pagination; usually a `MultiPolygon`, with coordinates kept as sent. |
| Road events | Optional park code, optional event type. | `roadEvents` | One complete response, no pagination; most parks return an empty feed, and an unrecognized park code returns every park's events. |

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
Articles, news releases, park audio, park videos, people, photo galleries, and photo gallery
assets sit after Webcams in the picker and take park codes, state codes, and search text like the
other collection groups; photo gallery assets also takes comma-separated gallery IDs.
Use **Load more** to request the next page of a collection group or **Cancel** to stop an in-flight
request; road events and park boundaries arrive as one response.
The demo shows loading, results, empty results, and failures. It keeps the key in memory and
does not save it. Close the standalone package window before building the demo to avoid
duplicate local-package resolution in Xcode.

## Products

| Product | Status | Dependencies |
| --- | --- | --- |
| `SwiftNPSData` | Authenticated collection execution, lazy page and item sequences, alerts, amenities, articles, campgrounds, news releases, park audio, park boundaries, park videos, parks, people, photo galleries, photo gallery assets, places, road events, things to do, tours, visitor centers, and webcams conveniences, typed failures. | `SwiftNPSDataModels`, swifty-networking, swift-http-types. |
| `SwiftNPSDataModels` | Generic collection envelope, queries, continuation rules, requests, and endpoints; alert, amenity, article, campground, news release, park audio, park boundary, park video, park, person, photo gallery, photo gallery asset, place, road event, thing to do, tour, visitor center, webcam, and shared detail models. | None. |

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
