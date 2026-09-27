# ``SwiftNPSVisitationModels``

Describe NPS visitation requests and preserve monthly records without a networking dependency.

## Overview

Create an inclusive month range with ``VisitationMonth`` and ``VisitationQuery``.
Unit codes retain their spelling and order. Empty codes, whitespace, controls, comma delimiters,
and reversed ranges fail locally.

```swift
let query = try VisitationQuery(
  end: .init(year: 2025, month: 2),
  start: .init(year: 2025, month: 1),
  unitCodes: ["ACAD"])
let request = NPSVisitationRequest.visitation(query: query)
let path = request.endpoint.path
```

A custom executor combines the encoded path with
`https://irmaservices.nps.gov/v3/rest/stats`, sends GET with Accept application/json,
refuses redirects, and decodes `[NPSVisitationRecord]`. No API key is required.

``VisitationEndpoint`` also accepts a consumer-defined Decodable response through
`init(path:)` or an in-service HTTPS URL through `init(link:)`. Endpoint construction
rejects credentials, fragments, traversal and API-key query parameters.

Monthly arrays preserve provider order, Int64 counts, and national null identifiers.
Missing months remain absent. National totals are monthly records, with no annual aggregation.
Responses are historical reports and carry no freshness or completeness guarantee.

## Topics

### Records and queries

- ``NPSVisitationRecord``
- ``VisitationMonth``
- ``VisitationQuery``

### Request descriptions

- ``NPSVisitationRequest``
- ``VisitationEndpoint``
