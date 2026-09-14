# ``SwiftNPSData``

Look up parks through the National Park Service Data API.

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
