# ``SwiftNPSData``

Find and browse parks through the National Park Service Data API.

## Overview

Create a client with a required private API key. On Apple platforms the client uses URLSession.
A supplied HTTPCore transport works on other supported platforms. The library never reads
environment variables or supplies a default key.

```swift
import SwiftNPSData
import SwiftNPSDataModels

let client = try NPSDataClient(apiKey: apiKey)
let code = try ParkCode("acad")
let page = try await client.parks(parkCode: code)
for park in page.data {
  print(park.fullName)
}
```

### Equivalent entry points

Choose one level for each lookup. Each call below sends one GET request to
`https://developer.nps.gov/api/v1/parks?parkCode=acad&limit=1&start=0`.

```swift
let page = try await client.parks(parkCode: code)

let request = ParkRequest.parks(parkCode: code)
let samePage = try await client.value(for: request)

let endpoint = Endpoint.parks(parkCode: code)
let anotherPage = try await client.send(endpoint)
```

All three return ``/SwiftNPSDataModels/ParksResponse``. The string-valued pagination metadata
and result order are preserved. An unknown code can return an empty data array. No first result
is selected, no next page is fetched, and no retries or redirects are performed.

### Queries and lazy pagination

Use one validated ``/SwiftNPSDataModels/ParkQuery`` across page iteration, individual park
iteration, and single-page requests:

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

let request = ParkRequest.parks(query: query)
let pages = client.parkPages(for: request)
let parks = client.parks(for: request)
let onePage = try await client.value(for: request)
let samePage = try await client.send(.parks(query: query))
```

Each loop starts an independent traversal. ``ParkPageSequence`` uses swifty-networking 1.1.0
pagination to fetch one page per read. ``ParkSequence`` drains that page before fetching another.
Construction performs no I/O, no pages are prefetched, and breaking iteration sends no later request.
Cancellation is checked before requests and when reading buffered parks. Any failure ends the
iterator; later reads return nil.

Queries explicitly default to `limit=50` and `start=0`, with both overridable. Pagination advances
by the number of returned parks, retaining filters, sorting, and authentication. A returned range
ending at the reported total completes iteration. An empty page is terminal only at or beyond
the total. Metadata strings remain unchanged in each page.

Unusable metadata, an unexpected offset, contradictory counts, or overflow throws
``NPSDataError/pagination(_:)`` before yielding the affected page. Previously yielded results do
not imply completion. Data can change between requests; neither sequence deduplicates, reorders,
or promises a stable snapshot.

A request made with `init(endpoint:)` or the existing single-code factory declares no continuation.
It yields only its one page even when the provider reports more results.

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

``/SwiftNPSDataModels/ParkRequest`` and ``/SwiftNPSDataModels/Endpoint`` are transport-independent
values. Their response types stay concrete, including consumer-defined Codable models.
See the models catalog for an example constrained request factory.

NPS destination information does not provide live campsite booking availability or reservations.
The package makes no freshness or completeness guarantee.

## Topics

### Client and configuration

- ``NPSDataClient``
- ``NPSDataConfiguration``

### Errors

- ``NPSDataError``

### Pagination

- ``ParkPageSequence``
- ``ParkSequence``
