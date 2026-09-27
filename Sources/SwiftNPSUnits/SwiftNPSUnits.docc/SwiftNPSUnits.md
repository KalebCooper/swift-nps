# ``SwiftNPSUnits``

Browse NPS administrative units, relationships and classifications without a Data API key.

## Overview

```swift
import SwiftNPSUnits
import SwiftNPSUnitsModels

let client = NPSUnitsClient()
let profiles = try await client.units(matching: "ACAD;YELL")
let linked = try await client.linkedUnits(unitCode: "NETN", kind: .all)
let designation = try await client.unitDesignation(code: "NP")
let request = NPSUnitsRequest.unitCollections()
let collections = try await client.value(for: request)
let sameCollections = try await client.send(.unitCollections())
```

The Apple convenience initializer uses URLSession. Other platforms inject a compatible transport.
Every client operation has an equivalent factory on ``/SwiftNPSUnitsModels/NPSUnitsRequest``
and ``/SwiftNPSUnitsModels/UnitEndpoint``. Custom endpoint response types are supported.

Use `units()` for all profiles, `units(matching:)` for provider search, and
`linkedUnits(unitCode:kind:)` for all, functional or logical links. Classification operations are
`unitCollections()`, `unitDesignations()`, `unitDesignation(code:)`, `unitSubtypes()`
and `unitSubtype(code:)`. Plural catalogs are arrays; singular lookups are objects.
Unknown profile searches and missing links can return an empty array. Unknown singular
catalog values can return an HTTP failure.

Requests remain within the Unit service base. Redirects, retries and automatic follow-up requests
are disabled. ``NPSUnitsError`` reports invalid inputs or preserves original transport failures,
including HTTP body/status/headers, decoding and cancellation. Cancellation is checked before sending
and after decoding. Records make no freshness, visitor-access or completeness guarantee.

## Topics

### Client

- ``NPSUnitsClient``
- ``NPSUnitsError``
