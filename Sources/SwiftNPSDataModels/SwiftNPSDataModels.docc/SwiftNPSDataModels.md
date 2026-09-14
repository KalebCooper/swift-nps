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

### Shared query values

``ParkQuery`` describes all six documented parks parameters: park codes, state codes, text search,
sort criteria, page limit, and start offset. It is immutable, Hashable, and Sendable.

```swift
let query = try ParkQuery(
  limit: 20, searchText: "history", sort: [.relevanceScore(.descending)],
  stateCodes: [StateCode("ME"), StateCode("MA")])
let endpoint = Endpoint.parks(query: query)
let request = ParkRequest.parks(query: query)
```

The defaults explicitly send `limit=50&start=0`. Limits must be positive and offsets nonnegative;
the official specification defines no maximum. ``ParkCode`` and ``StateCode`` validate syntax
without trimming or changing case. Empty code arrays omit the filter. Search text is preserved
and percent encoded, including empty text. Code arrays and sort criteria retain caller order.

``ParkSort`` supports full name, park code, and relevance in either direction. An empty sort array
uses NPS's full-name default; relevance must be the sole criterion. Comma-delimited serialization
follows the specification's descriptions and recorded requests, which conflict with its
`collectionFormat: multi` declarations.

For `.parks(query)`, a custom executor sends ``Endpoint/parks(query:)`` and decodes ``ParksResponse``.
To continue, call ``ParkQuery/next(after:)`` on the query that produced that page. The next query
retains every option except the offset, which advances by the returned item count. Nil means the
returned range reaches the reported total, or an empty page is at or beyond the total.

``ParkPaginationError`` reports invalid numeric metadata, an unexpected offset, contradictory
counts, or overflow. Validate before yielding a page; do not treat a validation failure as normal
completion. These rules interpret provider metadata without promising a stable snapshot.
Executable lazy page and park sequences belong to the SDK; this module contains no fetching loop.

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
are strings in recorded NPS responses. The existing single-code factory keeps its exact
`limit=1&start=0` request and declares no continuation. Single-page decoding preserves metadata
even when it cannot be used for pagination, and never selects a first result automatically.

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
- ``ParkQuery``
- ``ParkRequest``
- ``ParkSort``
- ``StateCode``

### Pagination

- ``ParkPaginationError``

### Responses

- ``Park``
- ``ParksResponse``
- ``ServiceErrorResponse``
