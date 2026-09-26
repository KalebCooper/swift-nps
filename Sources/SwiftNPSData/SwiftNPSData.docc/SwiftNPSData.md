# ``SwiftNPSData``

Explore National Park Service data with an async client, authentication, and automatic pagination.

## Overview

Use ``NPSDataClient`` to find parks, read alerts, browse campgrounds, and discover activities,
articles, multimedia, and other published park information. Import `SwiftNPSDataModels` for the
queries and response types.

[Get an NPS API key](https://www.nps.gov/subjects/developer/get-started.htm), then supply it at
runtime. These examples use the Apple-platform client in an async, throwing context:

```swift
import SwiftNPSData
import SwiftNPSDataModels

let client = try NPSDataClient(apiKey: apiKey)
let query = try ParkQuery(stateCodes: [StateCode("ME")])

for try await park in client.parks(query: query) {
  print(park.fullName)
}
```

Most collections follow this query-and-loop pattern. Browse the endpoint sections below for
supported filters and examples. Events are implemented on `main` and are not included in 0.6.0;
see [the changelog](https://github.com/KalebCooper/swift-nps/blob/main/CHANGELOG.md) for release details.

### Pages and requests

Use ``NPSDataClient/parkPages(query:)`` when you want whole pages and their metadata:

```swift
for try await page in client.parkPages(query: query) {
  print("Received \(page.data.count) of \(page.total) parks")
}
```

To fetch only the first page, create a reusable ``/SwiftNPSDataModels/NPSDataRequest``:

```swift
let request = NPSDataRequest.parks(query: query)
let page = try await client.value(for: request)
```

For lower-level access, ``NPSDataClient/send(_:)`` accepts a typed
``/SwiftNPSDataModels/Endpoint``. The request and endpoint APIs share authentication and error
handling with the collection conveniences.

### Pagination behavior

Pages are fetched on demand. Items drain the current page before fetching another, and breaking
out of a loop prevents later requests. Each loop starts an independent traversal; creating a
sequence sends nothing. Cancellation is checked before requests and while reading buffered items.
A failure ends that iterator.

Offset queries default to `limit=50` and `start=0`. They advance by the returned item count until
the reported total is reached. Invalid metadata throws ``NPSDataError/pagination(_:)`` before
yielding the affected page. Events use page numbers instead; park boundaries and road events
return single responses. An endpoint-only request also returns just one response.

Pages preserve provider metadata and result order. Results can change between requests, so
pagination does not guarantee a stable snapshot or remove duplicate items.

## Endpoint guides

Each section shows a client call and describes the endpoint's filters and response behavior.
For model fields and custom request execution, see ``/SwiftNPSDataModels``.

### Activities

``NPSDataClient/parkActivities(query:)`` and ``NPSDataClient/parkActivityPages(query:)`` search
`/activities` by activity identifiers, park codes, text, and sorting. Each page is
`NPSCollection<ParkActivity>`. The live service sorts by `name`, ascending or descending, and
answers another field such as `fullName` or `parkCode` with HTTP 400; fields are sent without
validation:

```swift
let query = try ParkActivityQuery(parkCodes: [ParkCode("drto")], sort: [.ascending("name")])
for try await activity in client.parkActivities(query: query) {
  print(activity.name)
}
```

Unlike `/activities/parks`, a page carries no nested parks; use
``NPSDataClient/parkActivityParks(query:)`` to see which parks offer an activity.

### Activity Parks

``NPSDataClient/parkActivityParks(query:)`` and ``NPSDataClient/parkActivityParkPages(query:)``
search `/activities/parks` by activity identifiers, park codes, text, and sorting. Each page is
`NPSCollection<ParkActivityParks>`. The live service sorts by `name`, ascending or descending, and
answers another field such as `fullName` or `parkCode` with HTTP 400; fields are sent without
validation:

```swift
let query = try ParkActivityParksQuery(parkCodes: [ParkCode("drto")], sort: [.ascending("name")])
for try await activity in client.parkActivityParks(query: query) {
  print(activity.name, activity.parks?.compactMap(\.parkCode) ?? [])
}
```

Park codes narrow each activity's `parks` to the requested parks as well as selecting the
activities, which keeps pages small; an unfiltered activity can list more than a hundred parks.

### Alerts

``NPSDataClient/parkAlerts(query:)`` and ``NPSDataClient/parkAlertPages(query:)`` read `/alerts` by
park codes, state codes, and text. Each page is `NPSCollection<ParkAlert>`, and alerts arrive in the
provider's order, since NPS documents no alerts sorting:

```swift
let query = try ParkAlertQuery(parkCodes: [ParkCode("acad"), ParkCode("yell")])
for try await alert in client.parkAlerts(query: query) {
  print(alert.category ?? "", alert.title)
}
```

Alerts describe current park conditions as NPS publishes them; the package makes no freshness
guarantee.

### Amenities

``NPSDataClient/amenities(query:)`` and ``NPSDataClient/amenityPages(query:)`` search
`/amenities` by identifiers and text; NPS documents no park, state, or sort parameter there. Each
page is `NPSCollection<Amenity>`.

``NPSDataClient/amenityParkPlaces(query:)`` and ``NPSDataClient/amenityParkPlacePages(query:)``
search `/amenities/parksplaces`, and ``NPSDataClient/amenityParkVisitorCenters(query:)`` and
``NPSDataClient/amenityParkVisitorCenterPages(query:)`` search `/amenities/parksvisitorcenters`,
by identifiers, park codes, text, and sorting. These two endpoints wrap each result in an extra
array. Their pages keep the provider's shape, `NPSCollection<[AmenityParkPlaces]>` and
`NPSCollection<[AmenityParkVisitorCenters]>`, where each element of `data` is one amenity's group,
observed so far with one entry each, and the offset advances by the number of groups. The item
methods return ``NPSFlattenedItemSequence``, which yields every entry of every group in provider
order with the same laziness, cancellation, and typed failures as ``NPSItemSequence``:

```swift
let query = try AmenityParkPlacesQuery(parkCodes: [ParkCode("acad")])
for try await amenity in client.amenityParkPlaces(query: query) {
  print(amenity.name, amenity.parks?.first?.places?.map(\.title) ?? [])
}
```

Listing an amenity at a park or place describes published facilities, not current availability.

### Articles

``NPSDataClient/articles(query:)`` and ``NPSDataClient/articlePages(query:)`` search `/articles` by
park codes, state codes, and text. Each page is `NPSCollection<Article>`. The endpoint answers a
sort value with HTTP 400, so the query offers no sort parameter:

```swift
let query = try ArticleQuery(parkCodes: [ParkCode("arch")], searchText: "geology")
for try await article in client.articles(query: query) {
  print(article.title, article.url ?? "")
}
```

Coordinates are published values kept as sent; most articles send none.

### Campgrounds

``NPSDataClient/campgrounds(query:)`` and ``NPSDataClient/campgroundPages(query:)`` search
`/campgrounds` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<Campground>`, and sort fields name campground properties without validation:

```swift
let query = try CampgroundQuery(parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
for try await campground in client.campgrounds(query: query) {
  print(campground.name, campground.campsites?.totalSites ?? "")
}
```

Published site counts, fees, and reservation links describe the campground; they are not live
campsite availability, and the package provides no booking or reservation support.

### Events

``NPSDataClient/parkEventPages(query:)`` and ``NPSDataClient/parkEvents(query:)`` lazily
execute page-number event queries. Each iterator starts independently, buffers at most one page,
and sends nothing until read. Breaking a loop prevents later requests. There is no prefetch,
reordering, deduplication, automatic retry, or stable-snapshot guarantee.

```swift
let query = try ParkEventQuery(
  dateEnd: .init("2026-10-02"), dateStart: .init("2026-09-26"),
  pageSize: 2, parkCodes: [ParkCode("yell")])
let request = NPSDataRequest.parkEvents(query: query)
let first = try await client.value(for: request)
let same = try await client.send(.parkEvents(query: query))
for try await page in client.pages(for: request) {
  print(page.page?.total as Any)
}
for try await event in client.items(for: request) {
  print(event.title, event.date as Any, event.location as Any)
}
```

The query defaults to unexpanded definitions, page 1 and size 10; valid sizes are 1...50.
`CalendarDate` requires real Gregorian dates in `yyyy-MM-dd` form. Invalid dates, reversed
ranges and invalid page settings fail locally. Dates and times in responses are preserved as text.
See ``/SwiftNPSDataModels/ParkEventQuery`` for all filters and their measured limitations.

``ParkEventPageSequence`` validates ordinary page metadata before yielding. Inconsistent pages
throw ``NPSDataError/pagination(_:)``; a nonempty errors array throws
``NPSDataError/eventService(_:)``, retaining the decoded response, status and headers. Unknown
error entries are not silently treated as warnings or empty results. Cancellation and any other
failure permanently end that iterator. Endpoint-only requests produce exactly one response.

Expansion is deliberately a single-response operation:
```swift
let expandedQuery = try ParkEventQuery(
  dateEnd: .init("2026-10-07"), dateStart: .init("2026-10-01"),
  expandRecurring: true, parkCodes: [ParkCode("yell")])
let expanded = try await client.value(for: .parkEvents(query: expandedQuery))
for event in expanded.data { print(event.id, event.date as Any) }
```

The provider returns a bare array for expansion, with no total or page metadata, and observed
later pages omitted occurrences. Request-based lazy expansion therefore throws
`eventExpansionUnavailable` before sending. Expanded single responses preserve repeated IDs and
provider order, but cannot guarantee every occurrence or strict date-range filtering. The SDK
does not invent continuation, expand recurrence locally, or remove duplicate identifiers.

### Lesson Plans

``NPSDataClient/lessonPlans(query:)`` and ``NPSDataClient/lessonPlanPages(query:)`` search
`/lessonplans` by lesson plan identifiers, park codes, state codes, text, and sorting. Each page
is `NPSCollection<LessonPlan>`. The live service sorts by `title`, ascending or descending, and
ignores an identifier it does not recognize rather than matching nothing; fields are sent without
validation:

```swift
let query = try LessonPlanQuery(parkCodes: [ParkCode("tusk")], sort: [.descending("title")])
for try await plan in client.lessonPlans(query: query) {
  print(plan.title, plan.gradeLevel ?? "")
}
```

Park codes select the lesson plans related to those parks without narrowing each plan's
`parks`, unlike activity and topic parks. Grade level and duration are the provider's descriptive
text, not parsed values.

### News Releases

``NPSDataClient/newsReleases(query:)`` and ``NPSDataClient/newsReleasePages(query:)`` search
`/newsreleases` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<NewsRelease>`. The live service sorts by `releaseDate` and `title` and answers
another field with HTTP 400; fields are sent without validation:

```swift
let query = try NewsReleaseQuery(
  parkCodes: [ParkCode("yell")], sort: [.descending("releaseDate")])
for try await release in client.newsReleases(query: query) {
  print(release.releaseDate ?? "", release.title)
}
```

Release and indexing timestamps are the provider's text without a time zone, kept as sent.

### Park Audio

``NPSDataClient/parkAudio(query:)`` and ``NPSDataClient/parkAudioPages(query:)`` search
`/multimedia/audio` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<ParkAudio>`. The live service sorts by `title` and answers another field such as
`relevanceScore` with HTTP 400; fields are sent without validation:

```swift
let query = try ParkAudioQuery(parkCodes: [ParkCode("choh")], sort: [.ascending("title")])
for try await audio in client.parkAudio(query: query) {
  print(audio.title, audio.versions?.first?.url ?? "")
}
```

Transcripts are the provider's plain text or HTML, and file sizes keep the provider's number, for
which NPS documents no unit.

### Park Boundaries

``NPSDataClient/parkBoundary(parkCode:)`` fetches `/mapdata/parkboundaries/{sitecode}`, one park's
boundary as a GeoJSON feature collection returned as one `ParkBoundary` with no pagination. Most
parks send a `MultiPolygon` and a few a `Polygon`, so read both typed accessors:

```swift
let boundary = try await client.parkBoundary(parkCode: ParkCode("drto"))
let geometry = boundary.features?.first?.geometry
if let polygons = geometry?.multiPolygon {
  print(polygons.count)
} else if let rings = geometry?.polygon {
  print(rings.first?.count ?? 0)
}
let request = NPSDataRequest.parkBoundary(parkCode: try ParkCode("drto"))
let sameBoundary = try await client.value(for: request)
```

An unknown park code fails with HTTP 404 and an `application/problem+json` body rather than the NPS
error envelope, so it surfaces as ``NPSDataError/transport(_:)`` holding the HTTP status failure
and its original body. Boundary geometry is published cartographic data, not a survey or a legal
record.

### Park Fees and Passes

``NPSDataClient/parkFeesAndPasses(query:)`` and ``NPSDataClient/parkFeesAndPassesPages(query:)``
search `/feespasses` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<ParkFeesAndPasses>`. The live service sorts by `parkCode` and `fullName`, ascending
or descending, and answers another field such as `name` or `relevanceScore` with HTTP 400; fields
are sent without validation:

```swift
let query = try ParkFeesAndPassesQuery(
  parkCodes: [ParkCode("havo")], sort: [.descending("parkCode")])
for try await park in client.parkFeesAndPasses(query: query) {
  print(park.parkCode, park.fees?.count ?? 0, park.passes?.count ?? 0)
}
```

Fee and pass `cost` stays the provider's text such as `"55.00"`, with no currency claimed. A
season date can carry only a `holiday` name with a null day and month, such as Memorial Day, which
floats from year to year and has no derivable date; `SeasonDate/date(in:calendar:)` takes the
caller's own calendar and returns nil for that form.

### Park Videos

``NPSDataClient/parkVideos(query:)`` and ``NPSDataClient/parkVideoPages(query:)`` search
`/multimedia/videos` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<ParkVideo>`. The live service sorts by `title` and answers another field such as
`relevanceScore` with HTTP 400; fields are sent without validation:

```swift
let query = try ParkVideoQuery(parkCodes: [ParkCode("crmo")], sort: [.ascending("title")])
for try await video in client.parkVideos(query: query) {
  print(video.title, video.versions?.first?.url ?? "")
}
```

Accessibility flags are the provider's JSON Booleans, caption files keep their language text, and
file sizes keep the provider's number or `null`, for which NPS documents no unit.

### Parking Lots

``NPSDataClient/parkingLots(query:)`` and ``NPSDataClient/parkingLotPages(query:)`` search
`/parkinglots` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<ParkingLot>`. The live service sorts by `name` and `parkCode`, ascending or
descending, and answers another field such as `title` or `relevanceScore` with HTTP 400; fields
are sent without validation:

```swift
let query = try ParkingLotQuery(parkCodes: [ParkCode("chsc")], sort: [.descending("name")])
for try await lot in client.parkingLots(query: query) {
  print(lot.name, lot.accessibility?.totalSpaces ?? 0)
}
```

Accessibility space counts are the provider's integers, correcting the misspelled
`numberofAdaVanAccessbileSpaces` key, and live status fields stay as sent though they are stale
and not guaranteed to be current.

### Parks

``NPSDataClient/parks(query:)`` and ``NPSDataClient/parkPages(query:)`` search `/parks` by park
codes, state codes, text, and sorting. The single-code lookup sends exactly
`/parks?parkCode=acad&limit=1&start=0` at each of its three levels and declares no continuation:

```swift
let code = try ParkCode("acad")
let page = try await client.parks(parkCode: code)
let samePage = try await client.value(for: .parks(parkCode: code))
let anotherPage = try await client.send(.parks(parkCode: code))
```

An unknown code can return an empty data array. No first result is selected, no next page is
fetched, and no retries or redirects are performed.

### Passport Stamp Locations

``NPSDataClient/passportStampLocations(query:)`` and
``NPSDataClient/passportStampLocationPages(query:)`` search `/passportstamplocations` by location
identifiers, park codes, state codes, text, and sorting. Each page is
`NPSCollection<PassportStampLocation>`. The live service orders by label for `name`, ascending or
descending, accepts `parkCode` with no observed ordering, and answers `label`, `title`,
`relevanceScore`, `fullName`, `type`, `id`, and unknown fields with HTTP 400; fields are sent
without validation:

```swift
let query = try PassportStampLocationQuery(
  parkCodes: [ParkCode("cato")], sort: [.ascending("name")])
for try await location in client.passportStampLocations(query: query) {
  print(location.label)
}
```

Park codes select the locations related to those parks without narrowing each location's `parks`,
and an unrecognized park code returns an empty page.

### People

``NPSDataClient/people(query:)`` and ``NPSDataClient/personPages(query:)`` search `/people` by
park codes, state codes, and text. Each page is `NPSCollection<Person>`. The endpoint answers every
sort value with HTTP 400, so the query offers no sort parameter:

```swift
let query = try PersonQuery(parkCodes: [ParkCode("yell")], searchText: "Moran")
for try await person in client.people(query: query) {
  print(person.title, person.quickFacts?.first?.value ?? "")
}
```

Coordinates are text kept as sent, usually empty, and profiles are the provider's HTML.

### Photo Galleries

``NPSDataClient/photoGalleries(query:)`` and ``NPSDataClient/photoGalleryPages(query:)`` search
`/multimedia/galleries` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<PhotoGallery>`. The live service sorts by `title` and answers another field such as
`relevanceScore` with HTTP 400; fields are sent without validation:

```swift
let query = try PhotoGalleryQuery(parkCodes: [ParkCode("thrb")], sort: [.ascending("title")])
for try await gallery in client.photoGalleries(query: query) {
  print(gallery.title, gallery.assetCount ?? 0)
}
```

A gallery carries one preview image, not its contents, and the provider's asset count. Rights and
usage constraints stay the provider's open text; upstream rights still apply.

### Photo Gallery Assets

``NPSDataClient/photoGalleryAssets(query:)`` and ``NPSDataClient/photoGalleryAssetPages(query:)``
search `/multimedia/galleries/assets` by gallery identifiers, asset identifiers, park codes, state
codes, text, and sorting. Each page is `NPSCollection<PhotoGalleryAsset>`. The live service sorts
by `title` and answers another field such as `relevanceScore` with HTTP 400; fields are sent
without validation:

```swift
let query = try PhotoGalleryAssetQuery(
  galleryIdentifiers: [NPSIdentifier("1FFC7EF8-155D-4519-3ECC-B652E2E95E20")])
for try await asset in client.photoGalleryAssets(query: query) {
  print(asset.title, asset.fileInfo?.url ?? "")
}
```

An uppercase gallery UUID returns that gallery's assets. The service matches identifiers case
sensitively and ignores a value that is not UUID-shaped, returning every asset instead, so a
mistyped identifier can yield the full collection rather than an error. An asset in several
galleries appears once per gallery; the sequences do not deduplicate. File sizes are the
provider's number, for which NPS documents no unit.

### Places

``NPSDataClient/places(query:)`` and ``NPSDataClient/placePages(query:)`` search `/places` by park
codes, state codes, and text. Each page is `NPSCollection<Place>`. The endpoint answers every sort
value with HTTP 400, so the query offers no sort parameter:

```swift
let query = try PlaceQuery(parkCodes: [ParkCode("acad")], searchText: "trail")
for try await place in client.places(query: query) {
  print(place.title, place.latLong ?? "")
}
```

Coordinates, flags, and descriptions are published text kept as sent, not parsed values.

### Road Events

``NPSDataClient/roadEvents(parkCode:type:)`` fetches `/roadevents`, a WZDx 4.1 GeoJSON feed
returned as one `RoadEventFeed` with no pagination. Both parameters are optional; `RoadEventType`
sends the provider's own spelling, so work zones are `WorkZone`, not the WZDx `work-zone`, which
the provider rejects:

```swift
let feed = try await client.roadEvents(parkCode: ParkCode("yell"), type: .workZone)
for feature in feed.features ?? [] {
  print(feature.properties?.coreDetails?.name ?? "", feature.geometry?.lineString?.count ?? 0)
}
let request = NPSDataRequest.roadEvents(parkCode: try ParkCode("yell"))
let sameFeed = try await client.value(for: request)
```

Every recorded feature is a `LineString`, read as `[longitude, latitude]` positions through
``/SwiftNPSDataModels/NPSGeometry/lineString``; a feature sent at another depth keeps its
coordinates rather than failing the feed. Most parks return an empty feed, and a valid type with
no matching events also returns an empty feed rather than an error. The provider silently ignores
a park code it does not recognize and returns every park's events. The feed is published by the
National Park Service under the license its metadata names, which this package's license does not
cover, and it is not an authoritative live closure service.

### Things to Do

``NPSDataClient/thingsToDo(query:)`` and ``NPSDataClient/thingToDoPages(query:)`` search
`/thingstodo` by identifiers, park codes, state codes, text, and sorting. Each page is
`NPSCollection<ThingToDo>`. NPS documents `relevanceScore` as the only sort field and answers
other fields, such as `title`, with HTTP 400, which the client reports as an ``NPSDataError``
without retrying:

```swift
let query = try ThingToDoQuery(
  parkCodes: [ParkCode("acad")], searchText: "hike", sort: [.descending("relevanceScore")])
for try await thing in client.thingsToDo(query: query) {
  print(thing.title, thing.duration ?? "")
}
```

Reservation, fee, and season fields are published descriptions, not live availability or a
booking service.

### Topic Parks

``NPSDataClient/parkTopicParks(query:)`` and ``NPSDataClient/parkTopicParkPages(query:)`` search
`/topics/parks` by topic identifiers, park codes, text, and sorting. Each page is
`NPSCollection<ParkTopicParks>`. The live service sorts by `name`, ascending or descending, and
answers another field such as `fullName` or `parkCode` with HTTP 400; fields are sent without
validation:

```swift
let query = try ParkTopicParksQuery(parkCodes: [ParkCode("mamc")], sort: [.ascending("name")])
for try await topic in client.parkTopicParks(query: query) {
  print(topic.name, topic.parks?.compactMap(\.parkCode) ?? [])
}
```

Park codes narrow each topic's `parks` to the requested parks as well as selecting the topics,
which keeps pages small; an unfiltered topic can list more than a hundred parks.

### Topics

``NPSDataClient/parkTopics(query:)`` and ``NPSDataClient/parkTopicPages(query:)`` search `/topics`
by topic identifiers, park codes, text, and sorting. Each page is `NPSCollection<ParkTopic>`. The
live service sorts by `name`, ascending or descending, and answers another field such as `fullName`
or `parkCode` with HTTP 400; fields are sent without validation:

```swift
let query = try ParkTopicQuery(parkCodes: [ParkCode("mamc")], sort: [.ascending("name")])
for try await topic in client.parkTopics(query: query) {
  print(topic.name)
}
```

Unlike `/topics/parks`, a page carries no nested parks; use ``NPSDataClient/parkTopicParks(query:)``
to see which parks relate to a topic.

### Tours

``NPSDataClient/tours(query:)`` and ``NPSDataClient/tourPages(query:)`` search `/tours` by
identifiers, park codes, state codes, text, and sorting. Each page is `NPSCollection<Tour>`.
`relevanceScore` is the only sort field the live service accepts; it answers other fields with
HTTP 400, which the client reports as an ``NPSDataError`` without retrying:

```swift
let query = try TourQuery(
  parkCodes: [ParkCode("cavo")], sort: [.descending("relevanceScore")])
for try await tour in client.tours(query: query) {
  print(tour.title, tour.stops?.map(\.ordinal) ?? [])
}
```

Durations and stop ordinals are published text kept as sent, and each tour links one park.

### Visitor Centers

``NPSDataClient/visitorCenters(query:)`` and ``NPSDataClient/visitorCenterPages(query:)`` search
`/visitorcenters` by park codes, state codes, text, and sorting. Each page is
`NPSCollection<VisitorCenter>`, and sort fields name visitor center properties without validation:

```swift
let query = try VisitorCenterQuery(parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
for try await center in client.visitorCenters(query: query) {
  print(center.name, center.operatingHours?.first?.description ?? "")
}
```

Published operating hours are descriptive text, not a live open-or-closed status.

### Webcams

``NPSDataClient/webcams(query:)`` and ``NPSDataClient/webcamPages(query:)`` search `/webcams` by
identifiers, park codes, state codes, and text. Each page is `NPSCollection<Webcam>`. The live
endpoint answers every sort value with HTTP 400, so `WebcamQuery` has no sort parameter:

```swift
let query = try WebcamQuery(parkCodes: [ParkCode("grte")])
for try await webcam in client.webcams(query: query) {
  print(webcam.title, webcam.status ?? "", webcam.isStreaming ?? false)
}
```

A webcam's status and streaming flag are published values, not a live check that the camera is
reachable, and its coordinates are not guaranteed to locate the camera.

## Authentication and failures

[NPS requires an API key](https://www.nps.gov/subjects/developer/guides.htm).
The client sends it only in `X-Api-Key`, never in a URL. Keep keys outside source control and
application bundles. Configuration descriptions are redacted; never log request headers.

Client operations throw ``NPSDataError``. Invalid local key syntax produces
``NPSDataError/invalidAPIKey``. Event error entries produce ``NPSDataError/eventService(_:)``.
A recognized gateway envelope produces
``NPSDataError/service(_:response:)``, preserving its open provider code along with the
original HTTP status, body, and headers. This includes rate-limit headers and `Retry-After`
when supplied. Other HTTP errors, malformed successful responses, connection failures, and
cancellation use ``NPSDataError/transport(_:)``. Cancellation maps to `TransportError.cancelled`.

NPS documents a default rolling limit of 1,000 requests per hour per key, but limits vary.
HTTP 429 is returned to the caller without automatic retry.

## Other platforms and custom networking

On Apple platforms, `NPSDataClient(apiKey:)` uses URLSession. On Linux or Android, enable the
`HTTPPortable` package trait and supply a transport to `NPSDataClient(configuration:transport:)`.
Use ``NPSDataConfiguration`` to supply the API key. The library does not read environment variables
or provide a default key.

``/SwiftNPSDataModels/NPSDataRequest`` and ``/SwiftNPSDataModels/Endpoint`` are
transport-independent values. Their response types stay concrete, including consumer-defined
Codable models. See the models catalog for how a custom executor interprets a request and its
continuation.

NPS destination information does not provide live campsite booking availability or reservations.
The package makes no freshness or completeness guarantee.

## Topics

### Client and configuration

- ``NPSDataClient``
- ``NPSDataConfiguration``

### Collections

- ``NPSDataClient/pages(for:)->NPSPageSequence<Item>``
- ``NPSDataClient/items(for:)->NPSItemSequence<Item>``
- ``NPSDataClient/value(for:)``
- ``NPSDataClient/send(_:)``
- ``NPSPageSequence``
- ``NPSItemSequence``

### Errors

- ``NPSDataError``

### Activities

- ``NPSDataClient/parkActivities(query:)``
- ``NPSDataClient/parkActivityPages(query:)``

### Activity Parks

- ``NPSDataClient/parkActivityParks(query:)``
- ``NPSDataClient/parkActivityParkPages(query:)``

### Alerts

- ``NPSDataClient/parkAlerts(query:)``
- ``NPSDataClient/parkAlertPages(query:)``

### Amenities

- ``NPSDataClient/amenities(query:)``
- ``NPSDataClient/amenityPages(query:)``
- ``NPSDataClient/amenityParkPlaces(query:)``
- ``NPSDataClient/amenityParkPlacePages(query:)``
- ``NPSDataClient/amenityParkVisitorCenters(query:)``
- ``NPSDataClient/amenityParkVisitorCenterPages(query:)``
- ``NPSFlattenedItemSequence``

### Articles

- ``NPSDataClient/articles(query:)``
- ``NPSDataClient/articlePages(query:)``

### Campgrounds

- ``NPSDataClient/campgrounds(query:)``
- ``NPSDataClient/campgroundPages(query:)``

### Events

- ``NPSDataClient/parkEventPages(query:)``
- ``NPSDataClient/parkEvents(query:)``
- ``ParkEventItemSequence``
- ``ParkEventPageSequence``

### Lesson Plans

- ``NPSDataClient/lessonPlans(query:)``
- ``NPSDataClient/lessonPlanPages(query:)``

### News Releases

- ``NPSDataClient/newsReleases(query:)``
- ``NPSDataClient/newsReleasePages(query:)``

### Park Audio

- ``NPSDataClient/parkAudio(query:)``
- ``NPSDataClient/parkAudioPages(query:)``

### Park Boundaries

- ``NPSDataClient/parkBoundary(parkCode:)``

### Park Fees and Passes

- ``NPSDataClient/parkFeesAndPasses(query:)``
- ``NPSDataClient/parkFeesAndPassesPages(query:)``

### Park Videos

- ``NPSDataClient/parkVideos(query:)``
- ``NPSDataClient/parkVideoPages(query:)``

### Parking Lots

- ``NPSDataClient/parkingLots(query:)``
- ``NPSDataClient/parkingLotPages(query:)``

### Parks

- ``NPSDataClient/parks(query:)``
- ``NPSDataClient/parkPages(query:)``
- ``NPSDataClient/parks(for:)``
- ``NPSDataClient/parkPages(for:)``
- ``NPSDataClient/parks(parkCode:)``

### Passport Stamp Locations

- ``NPSDataClient/passportStampLocations(query:)``
- ``NPSDataClient/passportStampLocationPages(query:)``

### People

- ``NPSDataClient/people(query:)``
- ``NPSDataClient/personPages(query:)``

### Photo Galleries

- ``NPSDataClient/photoGalleries(query:)``
- ``NPSDataClient/photoGalleryPages(query:)``

### Photo Gallery Assets

- ``NPSDataClient/photoGalleryAssets(query:)``
- ``NPSDataClient/photoGalleryAssetPages(query:)``

### Places

- ``NPSDataClient/places(query:)``
- ``NPSDataClient/placePages(query:)``

### Road Events

- ``NPSDataClient/roadEvents(parkCode:type:)``

### Things to Do

- ``NPSDataClient/thingsToDo(query:)``
- ``NPSDataClient/thingToDoPages(query:)``

### Topic Parks

- ``NPSDataClient/parkTopicParks(query:)``
- ``NPSDataClient/parkTopicParkPages(query:)``

### Topics

- ``NPSDataClient/parkTopics(query:)``
- ``NPSDataClient/parkTopicPages(query:)``

### Tours

- ``NPSDataClient/tours(query:)``
- ``NPSDataClient/tourPages(query:)``

### Visitor Centers

- ``NPSDataClient/visitorCenters(query:)``
- ``NPSDataClient/visitorCenterPages(query:)``

### Webcams

- ``NPSDataClient/webcams(query:)``
- ``NPSDataClient/webcamPages(query:)``
