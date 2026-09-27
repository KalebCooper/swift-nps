# ``SwiftNPSSpecies``

Read key-free NPSpecies checklist, full-list, and detailed-list responses.

## Overview

Each operation fetches the original whole list in one request. Checklist, full, and detailed
membership is preserved independently; no pagination or local list conversion is performed.

```swift
import SwiftNPSSpecies
import SwiftNPSSpeciesModels

let client = NPSSpeciesClient()
let query = try SpeciesQuery(categories: ["birds"], unitCode: "ACAD")
let checklist = try await client.speciesChecklist(query: query)
let request = NPSSpeciesRequest.speciesDetails(query: query)
let details = try await client.value(for: request)
let full = try await client.send(.species(query: query))
```

Use ``NPSSpeciesClient/init(transport:)`` with a compatible transport on Linux or Android.
Enable HTTPPortable when using swifty-networking's portable transport. URLSession convenience is
available on Apple platforms. Queries, records, and requests live in
``/SwiftNPSSpeciesModels``, which can be used without this SDK.

The client sends no Data API key, follows no redirect, and performs no automatic retry. Endpoints
remain within the fixed NPSpecies base. HTTP failures retain raw bytes, status, and headers; malformed
JSON and cancellation stay typed transport errors. An invalid category can produce HTTP 400 HTML.
An unknown unit returns an empty list. Availability and rate-limit policy are not guaranteed.

Category discovery uses a separate concrete XML operation:

```swift
let options = try await client.categoryOptions()
let request = SpeciesCategoriesRequest()
let sameOptions = try await client.value(for: request)
let alsoOptions = try await client.send(SpeciesCategoriesEndpoint())
```

The provider returns UTF-8 XML even with format=json. The SDK rejects malformed documents,
incomplete options, DTDs, and entity declarations; external entity resolution is disabled.
HTTP failures remain transport errors before parsing. Generic JSON execution is unchanged.

Value strings are alias guidance such as "1 or Mammals or Mammal". Preserve them as reference
text; submitting that whole string fails. Choose one alias yourself. Category names may include
interior spaces. The SDK never turns English alias prose into an enum or silently picks an alias.

Category XML runtime verification is pending on Android; local qualification is recorded separately.

## Topics

### Client and errors

- ``NPSSpeciesClient``
- ``NPSSpeciesError``
