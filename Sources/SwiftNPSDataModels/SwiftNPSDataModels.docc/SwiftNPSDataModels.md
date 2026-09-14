# ``SwiftNPSDataModels``

Typed park responses and requests without a networking dependency.

## Overview

Use ``ParkCode`` to validate one lookup code, ``Endpoint`` to describe its GET operation, and
``ParkRequest`` to store or extend a reusable lookup. Construction performs no I/O.

```swift
import SwiftNPSDataModels

let code = try ParkCode("acad")
let endpoint = Endpoint.parks(parkCode: code)
let request = ParkRequest.parks(parkCode: code)
```

An executor reads `request.resolution`. For `.endpoint`, send the endpoint path relative to
`https://developer.nps.gov/api/v1`, supply `Accept: application/json` and a private `X-Api-Key`
header, then decode the response body. This module never imports a transport or holds credentials.

### Extending application vocabulary

Factories belong in constrained extensions so an unannotated stored request retains its
concrete response type. Consumers can select their own response shape for a single endpoint:

```swift
struct ParkNames: Decodable, Sendable {
  struct Name: Decodable, Sendable {
    let fullName: String
  }

  let data: [Name]
}

extension ParkRequest where Response == ParkNames {
  static func names(parkCode: ParkCode) -> Self {
    let path = Endpoint.parks(parkCode: parkCode).path
    guard let endpoint = Endpoint<ParkNames>(path: path) else {
      preconditionFailure("The parks factory produces a valid relative path.")
    }
    return Self(endpoint: endpoint)
  }
}

let request = ParkRequest.names(parkCode: try ParkCode("acad"))
// ParkRequest<ParkNames>, usable by a custom executor or NPSDataClient.value(for:).
```

### Provider representation

``ParksResponse`` retains the `data`, `limit`, `start`, and `total` envelope. The last three
are strings in recorded NPS responses. The parks factory requests `limit=1&start=0` for one code,
retains any result the server returns, and performs no automatic pagination or selection.

``Park`` requires identity and names, while other documented fields remain optional.
Missing and null optional fields decode to nil; empty strings and arrays stay empty.
Coordinates, costs, dates, links, and comma-separated states stay in their provider form.
Open address, phone, activity, and topic identifiers are not closed enums. Unknown JSON fields,
including the currently undocumented `fees` field, are ignored by the typed model.

The [official specification](https://www.nps.gov/subjects/developer/customcf/swagger.json)
and real responses were checked on September 13, 2026. Its outer parks array declaration does
not match the live object envelope. The live recordings confirm the envelope and nested objects;
the schema's illustrative examples also differ in places from its property definitions.

### Endpoint boundaries

``Endpoint/init(path:)`` accepts only relative paths without fragments, traversal, or an
`api_key` query parameter. ``Endpoint/init(link:)`` accepts only HTTPS links below
`developer.nps.gov/api/v1/`, with no credentials or fragment. Public park and image URLs
are preserved as strings in the response; they are not executable API endpoints.

NPS data describes destinations, not live reservation availability, freshness, or completeness.

## Topics

### Requests

- ``Endpoint``
- ``ParkCode``
- ``ParkRequest``

### Responses

- ``Park``
- ``ParksResponse``
- ``ServiceErrorResponse``
