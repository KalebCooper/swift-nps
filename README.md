# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Swift models and a typed client for the
[National Park Service Data API](https://www.nps.gov/subjects/developer/api-documentation.htm).

The package provides `Codable` models and endpoint descriptions you can send through any networking
stack, plus an SDK that sends them for you through
[swifty-networking](https://github.com/KalebCooper/swifty-networking), with authentication, lazy
pagination, and typed failures. The
[documentation site](https://kalebcooper.github.io/swift-nps/documentation/) covers every type and
each endpoint group's behavior in detail.

## Status

Release 0.6.0 covers twenty-six endpoint groups. Only `/events` is not built.
[CHANGELOG.md](CHANGELOG.md) lists what each release added.

Twenty-four groups are offset-paginated collections that share one core: a validated query, the
`NPSCollection` envelope, a reusable `NPSDataRequest`, and a typed `Endpoint` for one page. Each
group's query is its item type plus `Query`, such as `ParkQuery` for `Park`.

| Group | Path | Item | Lazy pages | Lazy items |
| --- | --- | --- | --- | --- |
| Activities | `/activities` | `ParkActivity` | `parkActivityPages` | `parkActivities` |
| Activity parks | `/activities/parks` | `ParkActivityParks` | `parkActivityParkPages` | `parkActivityParks` |
| Alerts | `/alerts` | `ParkAlert` | `parkAlertPages` | `parkAlerts` |
| Amenities | `/amenities` | `Amenity` | `amenityPages` | `amenities` |
| Amenity park places | `/amenities/parksplaces` | `AmenityParkPlaces` | `amenityParkPlacePages` | `amenityParkPlaces` |
| Amenity park visitor centers | `/amenities/parksvisitorcenters` | `AmenityParkVisitorCenters` | `amenityParkVisitorCenterPages` | `amenityParkVisitorCenters` |
| Articles | `/articles` | `Article` | `articlePages` | `articles` |
| Campgrounds | `/campgrounds` | `Campground` | `campgroundPages` | `campgrounds` |
| Lesson plans | `/lessonplans` | `LessonPlan` | `lessonPlanPages` | `lessonPlans` |
| News releases | `/newsreleases` | `NewsRelease` | `newsReleasePages` | `newsReleases` |
| Park audio | `/multimedia/audio` | `ParkAudio` | `parkAudioPages` | `parkAudio` |
| Park fees and passes | `/feespasses` | `ParkFeesAndPasses` | `parkFeesAndPassesPages` | `parkFeesAndPasses` |
| Park videos | `/multimedia/videos` | `ParkVideo` | `parkVideoPages` | `parkVideos` |
| Parking lots | `/parkinglots` | `ParkingLot` | `parkingLotPages` | `parkingLots` |
| Parks | `/parks` | `Park` | `parkPages` | `parks` |
| Passport stamp locations | `/passportstamplocations` | `PassportStampLocation` | `passportStampLocationPages` | `passportStampLocations` |
| People | `/people` | `Person` | `personPages` | `people` |
| Photo galleries | `/multimedia/galleries` | `PhotoGallery` | `photoGalleryPages` | `photoGalleries` |
| Photo gallery assets | `/multimedia/galleries/assets` | `PhotoGalleryAsset` | `photoGalleryAssetPages` | `photoGalleryAssets` |
| Places | `/places` | `Place` | `placePages` | `places` |
| Things to do | `/thingstodo` | `ThingToDo` | `thingToDoPages` | `thingsToDo` |
| Topic parks | `/topics/parks` | `ParkTopicParks` | `parkTopicParkPages` | `parkTopicParks` |
| Topics | `/topics` | `ParkTopic` | `parkTopicPages` | `parkTopics` |
| Tours | `/tours` | `Tour` | `tourPages` | `tours` |
| Visitor centers | `/visitorcenters` | `VisitorCenter` | `visitorCenterPages` | `visitorCenters` |
| Webcams | `/webcams` | `Webcam` | `webcamPages` | `webcams` |

Two groups return one complete response with no pagination:

| Group | Path | Response | Method |
| --- | --- | --- | --- |
| Park boundaries | `/mapdata/parkboundaries/{sitecode}` | `ParkBoundary` | `parkBoundary(parkCode:)` |
| Road events | `/roadevents` | `RoadEventFeed` | `roadEvents(parkCode:type:)` |

Each query offers only the filters and sort the live endpoint accepts. Where the live API diverges
from the NPS specification, for example by rejecting a documented sort field or ignoring an
unrecognized identifier, the documentation for that group says so.

The package preserves the provider's data as sent: identifiers, timestamps, units, nulls, and
unknown codes. It provides no freshness, ordering, completeness, or availability guarantees.
Campground, fee, and reservation fields describe published information, not live campsite
availability or a booking service.

## Usage

[Get a private NPS API key](https://www.nps.gov/subjects/developer/get-started.htm), then reach any
collection at three equivalent levels: an everyday client method, a reusable `NPSDataRequest`, and a
typed `Endpoint` for one page. Parks show the pattern; every other collection follows it.

```swift
import SwiftNPSData
import SwiftNPSDataModels

// Supply your key at runtime; never put it in source or an application bundle.
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

All three levels share request construction, authentication, and typed failures. Each page is
`NPSCollection<Park>`, with the provider's string-valued `limit`, `start`, and `total` and its
result order.

### Pagination

Queries default to `limit=50` and `start=0`, both overridable. Each loop starts its own traversal,
and constructing a sequence sends nothing. Pages fetch on demand, individual items drain the current
page before fetching another, and breaking a loop prevents later requests.

Pagination advances by the returned item count and stops when that range reaches the reported
total. Invalid metadata, an unexpected offset, or contradictory counts throw
`NPSDataError.pagination` before the affected page is yielded. Results can change between
requests; the sequences do not deduplicate or promise a stable snapshot.

### Single-response groups

Park boundaries and road events return one response through the same levels:

```swift
let boundary = try await client.parkBoundary(parkCode: ParkCode("drto"))
let feed = try await client.roadEvents(parkCode: ParkCode("yell"), type: .workZone)
let sameFeed = try await client.value(for: .roadEvents(parkCode: try ParkCode("yell")))
```

`parks(parkCode:)` is a single-code lookup that sends exactly
`/parks?parkCode=acad&limit=1&start=0` and yields that one page.

### Authentication and failures

The client sends the key only in the `X-Api-Key` header, never in a URL. There is no default key
and no environment lookup. Every operation throws `NPSDataError`:

- `.invalidAPIKey` when the key is empty or unusable as a header value.
- `.service` for a recognized NPS error body, keeping the HTTP status, body, and headers, including
  rate-limit headers.
- `.pagination` for page metadata that cannot establish progress or completion.
- `.transport` for other HTTP statuses, decoding, connection, and cancellation failures. Redirects
  are reported here and never followed with the key.

NPS rate limits vary by key, and HTTP 429 is returned without automatic retry.

### Other platforms and custom networking

On Linux and Android, enable the `HTTPPortable` trait and create
`NPSDataClient(configuration:transport:)` with an `NPSDataConfiguration(apiKey:)` and an HTTPCore
transport. To use your own networking stack instead, depend on `SwiftNPSDataModels` alone: a
request's `resolution` holds the endpoint to send and, for a collection, a `next(after:)` rule for
the following page. `NPSDataRequest.init(endpoint:)` accepts your own response models.

## Example

[`Examples/SwiftNPSDataDemo`](Examples/SwiftNPSDataDemo) is an iOS 26 SwiftUI app that browses
each of the twenty-six endpoint groups. Pick a group, enter your API key, and tap **Search**.
Collection groups take park codes, state codes, and search text where the group supports them, and
page with **Load more**; **Cancel** stops an in-flight request. Park boundaries and road events show one response. The key stays in
memory and is never saved.

The demo references this package by local path. Open
`Examples/SwiftNPSDataDemo/SwiftNPSDataDemo.xcodeproj` with the package itself closed in Xcode,
since Xcode lets a local package be open in only one window.

## Products

| Product | What it is | Depends on |
| --- | --- | --- |
| `SwiftNPSDataModels` | Portable `Codable` response models, validated queries, `NPSCollection`, `NPSDataRequest`, and `Endpoint` values for every implemented group. Usable with any networking stack. | Nothing. |
| `SwiftNPSData` | `NPSDataClient`, which sends requests with authentication and lazy pagination, plus `NPSDataConfiguration` and one typed error, `NPSDataError`. It re-exports swifty-networking's `HTTPCore`, so `Transport` and `TransportError` need no import of their own. | `SwiftNPSDataModels`, swifty-networking, swift-http-types. |

A consumer with its own networking stack adds only `SwiftNPSDataModels` and fetches no dependency.

## Requirements

- Swift 6.2 or later.
- iOS, macOS, tvOS, visionOS, and watchOS 26 or later, Linux, or Android.
- A private NPS API key.
- `SwiftNPSData` depends on [swifty-networking](https://github.com/KalebCooper/swifty-networking)
  1.1.0 or later and [swift-http-types](https://github.com/apple/swift-http-types) 1.6.0 or later.
  On Apple platforms it sends through `URLSession`. On Linux and Android, enable the off-by-default
  `HTTPPortable` trait, which pulls in AsyncHTTPClient and SwiftNIO; a consumer who leaves the trait
  off never fetches or builds either.

## Installation

```swift
.package(url: "https://github.com/KalebCooper/swift-nps.git", from: "0.6.0")
```

On Linux or Android, enable the trait on the dependency:

```swift
.package(
  url: "https://github.com/KalebCooper/swift-nps.git", from: "0.6.0",
  traits: ["HTTPPortable"])
```

Then add `SwiftNPSData`, or `SwiftNPSDataModels` alone, to your target's dependencies.

## License

MIT. See [LICENSE](LICENSE). This project is independent of the National Park Service. NPS data
and media have their own [usage terms](https://www.nps.gov/aboutus/disclaimer.htm), which this
package's license does not grant.
