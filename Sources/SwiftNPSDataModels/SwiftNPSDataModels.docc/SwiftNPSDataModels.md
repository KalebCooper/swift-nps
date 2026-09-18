# ``SwiftNPSDataModels``

Typed NPS collection responses, queries, and requests without a networking dependency.

## Overview

This module describes National Park Service Data API operations as values. Alerts and parks are
the implemented endpoint groups, built on a generic core shared by every offset-paginated collection:
a validated ``NPSCollectionQuery``, the ``NPSCollection`` envelope, typed ``Endpoint`` values, and
the reusable ``NPSDataRequest``. Construction performs no I/O, and this module never imports a
transport or holds credentials.

```swift
import SwiftNPSDataModels

let query = try ParkQuery(
  limit: 20, searchText: "history", sort: [.descending("relevanceScore")],
  stateCodes: [StateCode("ME"), StateCode("MA")])
let endpoint = Endpoint.parks(query: query)
let request = NPSDataRequest.parks(query: query)
```

### Collection queries

A conforming ``NPSCollectionQuery`` names its collection path and item type, and lists its
parameters as ``NPSQueryItem`` values. ``Endpoint/collection(_:)`` serializes them in name order,
percent-encoding each value and joining list values with a literal comma, so equal queries always
produce identical paths. Queries are immutable, Hashable, and Sendable, and explicitly send
`limit=50&start=0` by default. Limits must be positive and offsets nonnegative; the official
specification defines no maximum.

``NPSSort`` names an open resource property in either direction. An empty sort array omits the
parameter, so NPS applies its own default order. Comma-delimited serialization follows the
specification's descriptions and recorded requests, which conflict with its
`collectionFormat: multi` declarations.

### Custom execution

An executor reads `request.resolution`. For `.endpoint`, send the endpoint path relative to
`https://developer.nps.gov/api/v1`, supply `Accept: application/json` and a private `X-Api-Key`
header, then decode the response body as the request's response type.

For `.collection`, the ``NPSCollectionResolution`` carries the first-page endpoint and the
erased query. Send ``NPSCollectionResolution/endpoint``, decode ``NPSCollection`` of the query's
item, and call ``NPSCollectionResolution/next(after:)`` while more pages are wanted. The next
resolution retains every option except the offset, which advances by the returned item count.
Nil means the returned range reaches the reported total, or an empty page is at or beyond the
total. The resolution holds no closures, so the request stays Hashable, and its concrete query
can be matched with a cast:

```swift
if case .collection(let resolution) = request.resolution,
  let query = resolution.query as? ParkQuery
{
  print(query.stateCodes)
}
```

``NPSPaginationError`` reports invalid numeric metadata, an unexpected offset, contradictory
counts, or overflow. Validate before yielding a page; do not treat a validation failure as normal
completion. These rules interpret provider metadata without promising a stable snapshot.
Executable lazy page and item sequences belong to the SDK; this module contains no fetching loop.

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

extension NPSDataRequest where Response == ParkNames {
  static func names(parkCode: ParkCode) -> Self {
    let path = Endpoint.parks(parkCode: parkCode).path
    guard let endpoint = Endpoint<ParkNames>(path: path) else {
      preconditionFailure("The parks factory produces a valid relative path.")
    }
    return Self(endpoint: endpoint)
  }
}

let request = NPSDataRequest.names(parkCode: try ParkCode("acad"))
// NPSDataRequest<ParkNames>, usable by a custom executor or NPSDataClient.value(for:).
```

A request created with ``NPSDataRequest/init(endpoint:)`` declares no continuation.

### Collection representation

``NPSCollection`` retains the `data`, `limit`, `start`, and `total` envelope of every
offset-paginated endpoint. The last three are strings in recorded NPS responses. Single-page
decoding preserves metadata even when it cannot be used for pagination, and never selects a
first result automatically.

### Alerts

``AlertQuery`` describes all five documented alerts parameters: park codes, state codes, text
search, page limit, and start offset. NPS documents no alerts sort parameter, so the query has
none. Empty code arrays omit the filter, and search text is preserved and percent encoded,
including empty text. Alerts pages are `NPSCollection<ParkAlert>`, from
``Endpoint/alerts(query:)`` or ``NPSDataRequest/alerts(query:)``.

``ParkAlert`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. The category stays an open string, although NPS documents
Danger, Caution, Information, and Park Closure. The `url` is kept as sent, including an empty
string, and `lastIndexedDate` stays the provider's zone-less timestamp text. Related road events
keep their open type strings. The specification and real responses were checked on September 17,
2026; its outer array declaration does not match the live object envelope.

### Parks

``ParkQuery`` describes all six documented parks parameters: park codes, state codes, text search,
sort criteria, page limit, and start offset. ``ParkCode`` and ``StateCode`` validate syntax
without trimming or changing case. Empty code arrays omit the filter. Search text is preserved
and percent encoded, including empty text. Code arrays and sort criteria retain caller order.
NPS documents `fullName`, `parkCode`, and `relevanceScore` as parks sort fields, and sorts by
full name when no criterion is given; relevance must be the sole criterion.

Parks pages are `NPSCollection<Park>`. The single-code factories, ``Endpoint/parks(parkCode:)``
and ``NPSDataRequest/parks(parkCode:)``, keep their exact `limit=1&start=0` request and declare
no continuation.

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

### Alerts

- ``AlertQuery``
- ``ParkAlert``

### Endpoints and errors

- ``Endpoint``
- ``ServiceErrorResponse``

### Collections

- ``NPSCollection``
- ``NPSCollectionQuery``
- ``NPSCollectionResolution``
- ``NPSDataRequest``
- ``NPSPaginationError``
- ``NPSQueryItem``
- ``NPSSort``

### Parks

- ``Park``
- ``ParkCode``
- ``ParkQuery``
- ``StateCode``
