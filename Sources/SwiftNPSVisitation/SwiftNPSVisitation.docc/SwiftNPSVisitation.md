# ``SwiftNPSVisitation``

Read NPS monthly visitation statistics without a Data API key.

## Overview

Import `SwiftNPSVisitationModels` for the query and record types.
The Apple convenience initializer uses URLSession. Other platforms inject a compatible transport.

```swift
import SwiftNPSVisitation
import SwiftNPSVisitationModels

let client = NPSVisitationClient()
let query = try VisitationQuery(
  end: .init(year: 2025, month: 2),
  start: .init(year: 2025, month: 1), unitCodes: ["ACAD"])
let months = try await client.visitation(query: query)
let request = NPSVisitationRequest.visitation(query: query)
let sameMonths = try await client.value(for: request)
let nationalMonths = try await client.nationalVisitation(year: 2025)
```

Everyday methods, reusable requests, and typed endpoints share one execution path.
``NPSVisitationClient/send(_:)`` executes a consumer-defined response described by
``/SwiftNPSVisitationModels/VisitationEndpoint``.

The provider returns bare arrays. National results have null unit identifiers and one record per
reported month. Sparse or unknown-unit results never become invented zeros. No aggregation,
pagination, caching, retries, or redirect following is performed.

``NPSVisitationError`` retains transport failures, including original HTTP response bytes, status
and headers. Cancellation is checked before sending and after decoding. A nonpositive national
year fails before transport.

## Topics

### Client

- ``NPSVisitationClient``
- ``NPSVisitationError``
