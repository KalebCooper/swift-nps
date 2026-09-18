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

Alerts, campgrounds, parks, and visitor centers are the implemented endpoint groups. They are built
on a generic collection core that executes any offset-paginated NPS collection the same way.

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
Construction performs no I/O, no pages are prefetched, and breaking iteration sends no later request.
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

### Alerts

``NPSDataClient/alerts(query:)`` and ``NPSDataClient/alertPages(query:)`` read `/alerts` by park
codes, state codes, and text. Each page is `NPSCollection<ParkAlert>`, and alerts arrive in the
provider's order, since NPS documents no alerts sorting:

```swift
let query = try AlertQuery(parkCodes: [ParkCode("acad"), ParkCode("yell")])
for try await alert in client.alerts(query: query) {
  print(alert.category ?? "", alert.title)
}
let request = NPSDataRequest.alerts(query: query)
let firstPage = try await client.value(for: request)
let samePage = try await client.send(.alerts(query: query))
```

Alerts describe current park conditions as NPS publishes them; the package makes no freshness
guarantee.

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

``/SwiftNPSDataModels/NPSDataRequest`` and ``/SwiftNPSDataModels/Endpoint`` are transport-independent
values. Their response types stay concrete, including consumer-defined Codable models.
See the models catalog for how a custom executor interprets a request and its continuation.

NPS destination information does not provide live campsite booking availability or reservations.
The package makes no freshness or completeness guarantee.

## Topics

### Alerts

- ``NPSDataClient/alerts(query:)``
- ``NPSDataClient/alertPages(query:)``

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

### Parks

- ``NPSDataClient/parks(query:)``
- ``NPSDataClient/parkPages(query:)``
- ``NPSDataClient/parks(for:)``
- ``NPSDataClient/parkPages(for:)``
- ``NPSDataClient/parks(parkCode:)``

### Visitor Centers

- ``NPSDataClient/visitorCenters(query:)``
- ``NPSDataClient/visitorCenterPages(query:)``

### Errors

- ``NPSDataError``
