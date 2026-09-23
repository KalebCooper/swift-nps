# ``SwiftNPSData``

Execute National Park Service Data API collection requests with authentication, lazy pagination,
and typed failures.

## Overview

Create a client with a required private API key. On Apple platforms the client uses URLSession.
A supplied HTTPCore transport works on other supported platforms. The library never reads
environment variables or supplies a default key.

```swift
import SwiftNPSData
import SwiftNPSDataModels

let client = try NPSDataClient(apiKey: apiKey)
let query = try ParkQuery(stateCodes: [StateCode("ME")])
for try await park in client.parks(query: query) {
  print(park.fullName)
}
```

Activities, activity parks, alerts, amenities, articles, campgrounds, lesson plans, news releases,
park audio, park boundaries, park fees and passes, park videos, parking lots, parks, passport
stamp locations, people, photo galleries, photo gallery assets, places, road events, things to do,
topic parks, topics, tours, visitor centers, and webcams are the implemented endpoint groups. The collection groups are built on a generic collection core that
executes any offset-paginated NPS collection the same way; park boundaries and road events are
single responses.

### Collection execution

Every collection operation is available at three equivalent levels: an everyday client method,
a reusable ``/SwiftNPSDataModels/NPSDataRequest``, and a typed ``/SwiftNPSDataModels/Endpoint``
for one page. For parks, one validated ``/SwiftNPSDataModels/ParkQuery`` drives all of them:

```swift
let query = try ParkQuery(
  limit: 20, searchText: "history", sort: [.descending("relevanceScore")],
  stateCodes: [StateCode("ME"), StateCode("MA")])

for try await page in client.parkPages(query: query) {
  print("Received \(page.data.count) of \(page.total) parks")
}

let request = NPSDataRequest.parks(query: query)
let pages = client.pages(for: request)
let parks = client.items(for: request)
let onePage = try await client.value(for: request)
let samePage = try await client.send(.parks(query: query))
```

The group conveniences, such as ``NPSDataClient/parkPages(query:)`` and
``NPSDataClient/parks(query:)``, delegate to the generic ``NPSDataClient/pages(for:)`` and
``NPSDataClient/items(for:)``. Single-page calls go through ``NPSDataClient/value(for:)``, which
sends the request's first endpoint with ``NPSDataClient/send(_:)``. Every path shares request
construction, authentication, and typed error mapping. Each page is
``/SwiftNPSDataModels/NPSCollection`` of the group's item type, with its string-valued `limit`,
`start`, and `total` and the provider's result order preserved.

### Lazy pagination

Each loop starts an independent traversal. ``NPSPageSequence`` uses swifty-networking 1.1.0
pagination to fetch one page per read. ``NPSItemSequence`` drains that page before fetching another.
Construction performs no I/O, no pages are prefetched, and breaking iteration sends no later
request.
Cancellation is checked before requests and when reading buffered items. Any failure ends the
iterator; later reads return nil.

Queries explicitly default to `limit=50` and `start=0`, with both overridable. Pagination advances
by the number of returned items, retaining filters, sorting, and authentication. A returned range
ending at the reported total completes iteration. An empty page is terminal only at or beyond
the total. Metadata strings remain unchanged in each page.

Unusable metadata, an unexpected offset, contradictory counts, or overflow throws
``NPSDataError/pagination(_:)`` before yielding the affected page. Previously yielded results do
not imply completion. Data can change between requests; neither sequence deduplicates, reorders,
or promises a stable snapshot.

A request made with `init(endpoint:)` declares no continuation, and yields only its one page even
when the provider reports more results.

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
let request = NPSDataRequest.parkActivities(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkActivities(query: query))
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
let request = NPSDataRequest.parkActivityParks(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkActivityParks(query: query))
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
let request = NPSDataRequest.parkAlerts(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkAlerts(query: query))
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
let request = NPSDataRequest.amenityParkPlaces(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.amenityParkPlaces(query: query))
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
let request = NPSDataRequest.articles(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.articles(query: query))
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
let request = NPSDataRequest.campgrounds(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.campgrounds(query: query))
```

Published site counts, fees, and reservation links describe the campground; they are not live
campsite availability, and the package provides no booking or reservation support.

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
let request = NPSDataRequest.lessonPlans(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.lessonPlans(query: query))
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
let request = NPSDataRequest.newsReleases(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.newsReleases(query: query))
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
let request = NPSDataRequest.parkAudio(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkAudio(query: query))
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
let request = NPSDataRequest.parkFeesAndPasses(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkFeesAndPasses(query: query))
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
let request = NPSDataRequest.parkVideos(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkVideos(query: query))
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
let request = NPSDataRequest.parkingLots(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkingLots(query: query))
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
let request = NPSDataRequest.passportStampLocations(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.passportStampLocations(query: query))
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
let request = NPSDataRequest.people(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.people(query: query))
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
let request = NPSDataRequest.photoGalleries(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.photoGalleries(query: query))
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
let request = NPSDataRequest.photoGalleryAssets(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.photoGalleryAssets(query: query))
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
let request = NPSDataRequest.places(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.places(query: query))
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
let request = NPSDataRequest.thingsToDo(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.thingsToDo(query: query))
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
let request = NPSDataRequest.parkTopicParks(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkTopicParks(query: query))
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
let request = NPSDataRequest.parkTopics(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.parkTopics(query: query))
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
let request = NPSDataRequest.tours(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.tours(query: query))
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
let request = NPSDataRequest.visitorCenters(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.visitorCenters(query: query))
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
let request = NPSDataRequest.webcams(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.webcams(query: query))
```

A webcam's status and streaming flag are published values, not a live check that the camera is
reachable, and its coordinates are not guaranteed to locate the camera.

### Authentication and failures

[NPS requires an API key](https://www.nps.gov/subjects/developer/guides.htm).
The client sends it only in `X-Api-Key`, never in a URL. Keep keys outside source control and
application bundles. Configuration descriptions are redacted; never log request headers.

Client operations throw ``NPSDataError``. A recognized gateway envelope produces
``NPSDataError/service(_:response:)``, preserving its open provider code along with the
original HTTP status, body, and headers. This includes rate-limit headers and `Retry-After`
when supplied. Other HTTP errors, malformed successful responses, connection failures, and
cancellation use ``NPSDataError/transport(_:)``. Cancellation maps to `TransportError.cancelled`.

NPS documents a default rolling limit of 1,000 requests per hour per key, but limits vary.
HTTP 429 is returned to the caller without automatic retry.

### Custom execution

``/SwiftNPSDataModels/NPSDataRequest`` and ``/SwiftNPSDataModels/Endpoint`` are
transport-independent values. Their response types stay concrete, including consumer-defined
Codable models. See the models catalog for how a custom executor interprets a request and its
continuation.

NPS destination information does not provide live campsite booking availability or reservations.
The package makes no freshness or completeness guarantee.

## Topics

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

### Client and configuration

- ``NPSDataClient``
- ``NPSDataConfiguration``

### Collections

- ``NPSDataClient/pages(for:)``
- ``NPSDataClient/items(for:)``
- ``NPSDataClient/value(for:)``
- ``NPSDataClient/send(_:)``
- ``NPSPageSequence``
- ``NPSItemSequence``

### Errors

- ``NPSDataError``

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
