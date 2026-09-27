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


## Geography and hierarchy

The six operations `unitGeographies(query:)`, `unitStates()`, `unitState(code:)`,
`unitCounty(state:county:)`, `unitPoints()` and `unitSelector()` return independent responses.
Geography is raw WKT or GML text inside JSON; no parsing, reprojection or geometry computation is performed.
Use optional exact detail values envelope, convexhull or feature and formats wkt or gml.
Omitting options retains the provider defaults. Unknown options are rejected locally because the
provider otherwise silently falls back to another representation.

States contain counties and preserve FIPS strings, including leading zeros. County lookup accepts
a full name such as "Hancock County", an ID or a FIPS code; shortened names can fail at the provider.
Point coordinates remain optional and are never inferred from boundaries.

The selector returns an array of nodes, each with a unit leaf and separate direct/indirect
active/inactive leaf lists. Lifecycle is an open integer and StateCodes is nullable text in a leaf,
unlike a profile's lifecycle text and state array. No automatic link traversal is performed.

## Topics

### Client

- ``NPSUnitsClient``
- ``NPSUnitsError``
