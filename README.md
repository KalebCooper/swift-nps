# swift-nps

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A Swift package for exploring the [National Park Service Data API](https://www.nps.gov/subjects/developer/api-documentation.htm).
Find parks, read alerts, browse campgrounds, and discover things to do with typed models and
an async client that handles authentication and pagination.

[API documentation](https://kalebcooper.github.io/swift-nps/documentation/) ·
[Installation](#installation) · [Demo app](#example)

## Status

The latest release, **0.6.0**, includes park and visitor information, activities and topics,
articles and multimedia, fees and passes, educational resources, park boundaries, and road events.
Events are implemented on `main` and are **unreleased**. Key-free IRMA visitation statistics are
also available in the unreleased `SwiftNPSVisitation` and `SwiftNPSVisitationModels` products. See the [changelog](CHANGELOG.md) for
release details.

## Usage

[Get an NPS API key](https://www.nps.gov/subjects/developer/get-started.htm) and supply it at runtime.
The following examples use the Apple-platform client inside an async, throwing context.

### Find parks

```swift
import SwiftNPSData
import SwiftNPSDataModels

let client = try NPSDataClient(apiKey: apiKey)
let query = try ParkQuery(stateCodes: [StateCode("ME")])

for try await park in client.parks(query: query) {
  print(park.fullName)
}
```

The client fetches pages as you iterate. Break out of the loop when you have enough results.
Use `searchText`, `parkCodes`, or `limit` to narrow the query:

```swift
let query = try ParkQuery(limit: 10, searchText: "history")

for try await park in client.parks(query: query) {
  print(park.fullName)
}
```

### Read alerts for a park

Other collections follow the same query-and-loop pattern:

```swift
let query = try ParkAlertQuery(parkCodes: [ParkCode("acad")])

for try await alert in client.parkAlerts(query: query) {
  print(alert.title)
}
```

### Fetch one page

Use a request when you want one response, or `parkPages(query:)` to iterate whole pages:

```swift
let query = try ParkQuery(limit: 10)
let page = try await client.value(for: .parks(query: query))
print(page.data.count)
```

A page retains the results in `data` and the provider's pagination metadata.

The client sends your key in the `X-Api-Key` header and throws `NPSDataError` for request failures.
Keep the key outside source control and application bundles. Requests are not automatically retried.

For all supported collections, filters, error handling, custom transports, and event limitations,
see the [client guide](https://kalebcooper.github.io/swift-nps/documentation/swiftnpsdata/).

### Read monthly visitation

```swift
import SwiftNPSVisitation
import SwiftNPSVisitationModels

let visits = NPSVisitationClient()
let months = try await visits.nationalVisitation(year: 2025)
```

National results are monthly records. Missing months remain absent; no annual total is calculated.
IRMA statistics use no Data API key. See the Visitation DocC catalogs for unit and month queries.

### Read a species checklist

```swift
import SwiftNPSSpecies
import SwiftNPSSpeciesModels

let species = NPSSpeciesClient()
let query = try SpeciesQuery(categories: ["birds"], unitCode: "ACAD")
let checklist = try await species.speciesChecklist(query: query)
```

Use `species.categoryOptions()` to read the provider's category alias guidance. The XML decoder
preserves its exact values; Android runtime qualification for category discovery is pending.

Checklist, full, and detailed lists preserve their separate membership. These inventories do not
describe current wildlife sightings. The Species products are unreleased and require no key.

### Explore landmarks

```swift
import SwiftNPSLandmarks

let landmarks = try await NPSLandmarksClient().landmarks(stateCode: "ME")
```

These unreleased records preserve landmark and county identifiers. Designation does not imply
public access or NPS ownership. Browse county relationships, the state/landmark index, and ownership
classifications through the same client. See the Landmark DocC catalog for query and response shapes.

### Find administrative units

```swift
import SwiftNPSUnits
import SwiftNPSUnitsModels

let units = try await NPSUnitsClient().units(matching: "ACAD;YELL")
```

The unreleased Unit products preserve administrative identifiers, nullable fields and provider order.
Use the Unit DocC guides for linked units, classifications, state/county hierarchies, points,
selector groups and raw WKT/GML geography.

## Example

The [SwiftUI demo app](Examples/SwiftNPSDataDemo) lets you browse the supported endpoint groups,
search, and load more results. The Data API tab keeps your entered key in memory.
The IRMA tab offers Landmarks, Species, Taxonomy, Units, and Visitation without a key.

Open [SwiftNPSDataDemo.xcodeproj](Examples/SwiftNPSDataDemo/SwiftNPSDataDemo.xcodeproj) in Xcode
with the standalone package window closed, since Xcode opens a local package in only one window
at a time.

## Taxonomy (unreleased)

```swift
import SwiftNPSTaxonomy

let taxon = try await NPSTaxonomyClient().taxonSummary(code: "81838", kind: .nps)
```

Choose NPS taxon code or ITIS TSN explicitly: the same number can identify different taxa.
Taxonomy also supports explicit GET/POST code lists and lazy page/item traversal. See its DocC catalogs
for filters, continuation rules, and source/category/rank discovery.

## Products

| Product | Use it for |
| --- | --- |
| `SwiftNPSData` | An async client with authentication, lazy pagination, and typed errors. Uses [swifty-networking](https://github.com/KalebCooper/swifty-networking), with URLSession on Apple platforms. |
| `SwiftNPSDataModels` | `Codable` models, validated queries, and typed requests and endpoints. Has no dependencies and works with your own networking stack. |
| `SwiftNPSLandmarks` | Key-free state/county discovery and landmark records. |
| `SwiftNPSLandmarksModels` | Landmark records and independent request descriptions. |
| `SwiftNPSSpecies` | Key-free checklist, full, and detailed species lists. |
| `SwiftNPSSpeciesModels` | Portable list records, safe queries, and inspectable requests. |
| `SwiftNPSTaxonomy` | Key-free explicit-namespace lookup, name search, and classification discovery. |
| `SwiftNPSTaxonomyModels` | Distinct basic/profile records and independent request descriptions. |
| `SwiftNPSUnits` | Key-free unit profiles, linked units, and classification catalogs. |
| `SwiftNPSUnitsModels` | Administrative records and independent request descriptions. |
| `SwiftNPSVisitation` | Key-free monthly unit and national visitation statistics. |
| `SwiftNPSVisitationModels` | Portable monthly records, validated ranges, and inspectable requests. |

The package preserves NPS data, including provider identifiers, timestamps, and unknown codes.
It describes published park information; it does not provide live campsite availability or bookings.

## Requirements

- Swift 6.2 or later.
- iOS, macOS, tvOS, visionOS, or watchOS 26 or later; Linux and Android are also supported.
- An NPS API key for Data API requests. IRMA Landmarks, Species, Taxonomy, Units, and Visitation require no key.

## Installation

In Xcode, add `https://github.com/KalebCooper/swift-nps.git` as a package dependency.
For a `Package.swift` manifest, add:

```swift
.package(url: "https://github.com/KalebCooper/swift-nps.git", from: "0.6.0")
```

Then add both products to the target that uses the client:

```swift
.product(name: "SwiftNPSData", package: "swift-nps"),
.product(name: "SwiftNPSDataModels", package: "swift-nps"),
```

If you only need models and request descriptions, add `SwiftNPSDataModels` alone.

On Linux or Android, enable the portable transport trait:

```swift
.package(
  url: "https://github.com/KalebCooper/swift-nps.git",
  from: "0.6.0",
  traits: ["HTTPPortable"]
)
```

Create the client with `NPSDataClient(configuration:transport:)` and a compatible transport.
See the [client guide](https://kalebcooper.github.io/swift-nps/documentation/swiftnpsdata/)
for networking options.

## Learn more

- [API documentation](https://kalebcooper.github.io/swift-nps/documentation/): guides and the full reference for both products.
- [Models guide](https://kalebcooper.github.io/swift-nps/documentation/swiftnpsdatamodels/): response fields, queries, and custom request execution.
- [Changelog](CHANGELOG.md): changes by release.
- [Contributing](CONTRIBUTING.md): local setup, checks, and pull requests.

## License

[MIT](LICENSE). This project is independent of the National Park Service. NPS data and media
have their own [usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
