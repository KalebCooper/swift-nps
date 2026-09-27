# ``SwiftNPSLandmarksModels``

Decode National Natural Landmark records and describe requests without a networking dependency.

## Overview

The client targets `https://irmaservices.nps.gov/NNLApi/v1`; all built-in operations are GET routes under `/api`. Records preserve provider identifiers and ordering. A landmark designation does not establish public access or NPS ownership.

```swift
import SwiftNPSLandmarksModels

let request = try NPSLandmarksRequest.landmarks(stateCode: "ME")
let path = request.endpoint.path
```

## Discovery shapes

- `landmarkStates()`: an array of states, including the raw unknown code `--`.
- `landmarkState(stateCode:)`: one state object.
- `landmarkCounty(query:)`: one county relationship, even without filters.
- `landmarks(stateCode:)` and `landmarks(query:)`: ordinary records with primary and optional secondary states.
- `landmarks(countyID:)`: county-enriched records, including CountyID and optional CountyLabel/StateCode. These are `LandmarkWithCounty`, not ordinary records.

`LandmarkQuery` retains Code, CountyID, ID and StateCode independently in that order. CountyID identifies a county; ID identifies the landmark in these records. IDs in 1...Int32.max are required because invalid or nonpositive filters can cause the provider to return the entire catalog. Omitted filters are not sent. Text is encoded without trimming or case normalization.

Acreage uses Swift's floating-point numeric type. AuthoritativeURL remains optional raw text; no URL or access status is invented. Unknown landmark searches return empty arrays; unknown state or county object queries may fail with HTTP500. There is no pagination metadata, caching, retry, or rate-limit guarantee.

## Custom execution

Requests and endpoints are Hashable and Sendable and perform no I/O. The generic response is consumer-definable and the endpoint initializer confines paths and links to the service base. This module depends only on Foundation and Swift.

## Relationships and ownership

`landmarkSiteCounties(query:)` preserves multiple county relationships for a landmark. `landmarkStateCounties(query:)` uses the narrower `LandmarkStateCountyQuery` with CountyID/StateCode only; its rows contain county/state labels without landmark IDs.

`statesAndLandmarks()` returns a flat index of `LandmarkStateGroup` rows. It has no filters or nested groups; repeated site codes and cross-state membership remain repeated.

`landmarksWithCounty(query:)` preserves the provider's enriched shape. Code/ID queries can return CountyID zero with null CountyLabel/StateCode; a county filter can populate those fields. Zero is response data, not a valid query identifier.

`landmarkOwners(query:)` accepts only Code/ID through `LandmarkOwnerQuery`. A landmark may have several open numeric ownership categories; labels such as Private, Federal, or State do not establish public access or NPS ownership.

## Topics

### Records

- ``LandmarkCounty``
- ``LandmarkOwner``
- ``LandmarkState``
- ``LandmarkStateCounty``
- ``LandmarkStateGroup``
- ``LandmarkWithCounty``
- ``NPSLandmark``

### Requests

- ``LandmarkEndpoint``
- ``LandmarkOwnerQuery``
- ``LandmarkQuery``
- ``LandmarkStateCountyQuery``
- ``NPSLandmarksRequest``
