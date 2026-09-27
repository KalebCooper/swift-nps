# ``SwiftNPSUnitsModels``

Describe Unit service requests and preserve administrative records without transport dependencies.

## Overview

```swift
import SwiftNPSUnitsModels

let request = try NPSUnitsRequest.units(matching: "ACAD;YELL")
let path = request.endpoint.path
let endpoint = try UnitEndpoint.linkedUnits(unitCode: "NETN", kind: .all)
```

A custom executor appends the encoded path to `https://irmaservices.nps.gov/Unit/v2/api`,
sends GET with Accept application/json, refuses redirects, and decodes the endpoint's response type.
No key is required. ``UnitEndpoint`` accepts consumer-defined Decodable responses, but rejects
origin changes, traversal, credentials, fragments and API-key query parameters.

Profiles and linked units are arrays. Collections, designations and subtypes are arrays of
catalog objects containing ordered ``UnitSummary`` values. Singular designation and subtype
lookups return one object; an unknown catalog code may produce an HTTP failure.

Search terms match provider codes, names, lifecycle, designation or subtype. Semicolons separate
multiple terms; code lists match their units, while other terms refine the provider search.
Text is preserved and encoded without uppercasing or trimming. Empty text, control characters,
path separators and ambiguous percent escapes fail locally.
Administrative codes such as NPS and NETN do not use the Data API's four-character ParkCode.

``NPSUnit`` retains nullable network, region, designation and state arrays. Lifecycle and
classification codes stay open strings. No joining, deduplication, aggregation or pagination occurs.

## Topics

### Records

- ``NPSUnit``
- ``UnitCollection``
- ``UnitDesignation``
- ``UnitSubtype``
- ``UnitSummary``

### Requests

- ``NPSUnitsRequest``
- ``UnitEndpoint``
- ``UnitLinkKind``
