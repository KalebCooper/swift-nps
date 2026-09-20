# ``SwiftNPSDataModels``

Typed NPS collection responses, queries, and requests without a networking dependency.

## Overview

This module describes National Park Service Data API operations as values. Alerts, amenities,
campgrounds, parks, things to do, and visitor centers are the implemented endpoint groups, built on a generic
core shared by every offset-paginated collection: a validated ``NPSCollectionQuery``, the ``NPSCollection`` envelope, typed ``Endpoint`` values, and
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

### Shared shapes

Shapes the provider sends identically across groups are top-level `NPS` types. ``NPSImage`` is
the one image type: every image object NPS sends is a variant that differs only by whether
`crops` and `description` are present, and each missing key decodes to nil. Its crops are
``NPSImageCrop``, whose ``NPSImageCrop/aspectRatio`` is text because the provider sends a JSON
number on some paths (`/parks`, `/campgrounds`, `/visitorcenters`) and a JSON string on others
(`/thingstodo`), and can mix both in one response; a string is stored exactly as sent and a number
as its decimal text, with ``NPSImageCrop/ratio`` parsing it when numeric. ``NPSRelatedPark`` is
the park summary attached to records from other groups, with `states` kept as the provider's
comma-joined text. ``NPSQuickFact``, ``NPSRelatedOrganization``, and ``NPSConstraintsInfo`` are
decoded shapes for groups this package does not yet query; they are documented only as the
provider sends them.

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

### Amenities

``AmenityQuery`` describes the four documented `/amenities` parameters: identifiers, text search,
page limit, and start offset; NPS documents no park, state, or sort parameter there, so the query
has none. ``AmenityParkPlacesQuery`` and ``AmenityParkVisitorCentersQuery`` describe the six
documented parameters of `/amenities/parksplaces` and `/amenities/parksvisitorcenters`:
identifiers, park codes, text search, sort criteria, page limit, and start offset. Identifiers are
``NPSIdentifier`` values sent as `id`. Empty identifier, code, and sort arrays omit the parameter,
and sort fields are sent without validation because NPS lists no sort fields.

``Amenity`` requires an identifier and name and keeps the provider's `categories` text, which
the specification omits. The park places and park visitor centers endpoints wrap each result in an
extra array: every element of a page's `data` is one amenity's group, observed so far with one
entry each. Their pages are therefore `NPSCollection<[AmenityParkPlaces]>` and
`NPSCollection<[AmenityParkVisitorCenters]>`, kept as sent; ``NPSCollectionQuery/next(after:)``
advances by the number of groups, which the live service counts against `limit`. Each entry lists
parks as ``AmenityParkPlaces/RelatedPark`` or ``AmenityParkVisitorCenters/RelatedPark`` entries,
each holding an ``NPSRelatedPark`` summary decoded from the same flat provider object alongside
``AmenityParkPlaces/Place`` or ``AmenityParkVisitorCenters/VisitorCenterSummary`` values, read
from the lowercase `visitorcenters` key. Places and visitor center summaries carry links, so they
are not ``NPSNamedItem``. Unknown JSON fields are ignored.

The specification and real responses were checked on September 17, 2026. The live responses carry
`categories` on amenities and the extra group array on the park endpoints, and the models follow
them.

### Campgrounds

``CampgroundQuery`` describes all six documented campgrounds parameters: park codes, state codes,
text search, sort criteria, page limit, and start offset. NPS documents sorting by resource
properties without listing them, so sort fields are sent without validation. Empty code and sort
arrays omit the parameter, and search text is preserved and percent encoded, including empty text.
Campgrounds pages are `NPSCollection<Campground>`, from ``Endpoint/campgrounds(query:)`` or
``NPSDataRequest/campgrounds(query:)``.

``Campground`` requires an identifier and name; other documented fields remain optional, and
unknown JSON fields are ignored. Addresses, contacts, multimedia, and operating hours use the
shared ``NPSAddress``, ``NPSContacts``, ``NPSMultimedia``, and ``NPSOperatingHours`` types.
Fees are ``NPSFee``, the same shape as park entrance fees and passes; images and passport stamp
images are both ``NPSImage``, the same as visitor centers, with numeric crop aspect ratios stored
as text.
``Campground/Accessibility``, ``Campground/Amenities``, and ``Campground/Campsites`` keep every
value as sent: flags such as `rvAllowed` stay `"0"` or `"1"`, lengths and site counts stay text,
and amenity descriptions such as `"Yes - seasonal"` stay open strings. The provider's lowercase
`regulationsurl` key decodes as ``Campground/regulationsUrl``.

Site counts, fees, and reservation links are published descriptions, not live campsite
availability or a booking service. The specification and real responses were checked on
September 17, 2026. The specification spells nested keys in lowercase, names the reservation
fields differently, and declares fees, images, and operating hours as arrays of strings; the live
responses send camelCase keys and objects, and add passport stamp fields, which the model follows.

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
Activities and topics are ``NPSNamedItem`` values, the same shape things to do use. Images are
``NPSImage`` values without crops or descriptions on this path. Open address,
phone, activity, and topic identifiers are not closed enums. Unknown JSON fields,
including the currently undocumented `fees` field, are ignored by the typed model.

The [official specification](https://www.nps.gov/subjects/developer/customcf/swagger.json)
and real responses were checked on September 13, 2026. Its outer parks array declaration does
not match the live object envelope. The live recordings confirm the envelope and nested objects;
the schema's illustrative examples also differ in places from its property definitions.

### Things to Do

``ThingToDoQuery`` describes all seven documented things to do parameters: identifiers, park
codes, state codes, text search, sort criteria, page limit, and start offset. ``NPSIdentifier``
accepts any nonempty identifier without whitespace or control characters, preserving case and
performing no format check, and identifiers are sent as `id`. Empty identifier, code, and sort
arrays omit the parameter, and search text is preserved and percent encoded, including empty text.
Things to do pages are `NPSCollection<ThingToDo>`, from ``Endpoint/thingsToDo(query:)`` or
``NPSDataRequest/thingsToDo(query:)``.

NPS documents `relevanceScore` as the only things to do sort field, usually as
`.descending("relevanceScore")`; without a sort, results are ordered by date last modified. The
live service answers other fields, such as `title`, with HTTP 400 rather than ignoring them. Sort
fields are still sent without validation, so that failure comes from NPS rather than the query.

``ThingToDo`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. Activities and topics are ``NPSNamedItem``, the same as parks.
Images are the shared ``NPSImage``; on this path they carry a description and crops whose aspect
ratio arrives as text such as `"1.78"`, which ``NPSImageCrop`` keeps as sent. Related parks are
``NPSRelatedPark`` summaries. Flags such as `isReservationRequired` and `doFeesApply`
stay the provider's `"true"` or `"false"` text, and coordinates, durations, and descriptions stay
as sent, including empty strings and HTML. The `relatedOrganizations` and `amenities` arrays are
empty in every recorded response, so their element shape is unknown and they are not decoded.

The specification and real responses were checked on September 17, 2026. The specification spells
`arePetsPermittedwithRestrictions` and the crop `aspectratio` in lowercase and types the ratio as an
integer, omits image descriptions, `credit`, and `amenities`, and says an invalid sort property is
ignored; the live responses differ, and the model follows them.

### Visitor Centers

``VisitorCenterQuery`` describes all six documented visitor centers parameters: park codes, state
codes, text search, sort criteria, page limit, and start offset. NPS documents sorting by resource
properties without listing them, so sort fields are sent without validation. Empty code and sort
arrays omit the parameter, and search text is preserved and percent encoded, including empty
text. Visitor centers pages are `NPSCollection<VisitorCenter>`, from
``Endpoint/visitorCenters(query:)`` or ``NPSDataRequest/visitorCenters(query:)``.

``VisitorCenter`` requires an identifier and name; other documented fields remain optional, and
unknown JSON fields are ignored. Addresses, contacts, multimedia, and operating hours use the same
``NPSAddress``, ``NPSContacts``, ``NPSMultimedia``, and ``NPSOperatingHours`` types as ``Park``.
Visitor center images and passport stamp images are both the shared ``NPSImage``; stamp crops
carry a numeric aspect ratio the crop stores as text. The passport stamp flag
stays the provider's `"0"` or `"1"` string, and coordinates, links, and `lastIndexedDate` stay as
sent, including empty strings. The specification and real responses were checked on September 17,
2026. The specification declares `contacts` an array of strings and the passport stamp flag a
Boolean; the live responses send a contacts object and a string flag, which the model follows.

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

### Amenities

- ``Amenity``
- ``AmenityParkPlaces``
- ``AmenityParkPlacesQuery``
- ``AmenityParkVisitorCenters``
- ``AmenityParkVisitorCentersQuery``
- ``AmenityQuery``

### Campgrounds

- ``Campground``
- ``CampgroundQuery``

### Endpoints and errors

- ``Endpoint``
- ``ServiceErrorResponse``

### Collections

- ``NPSCollection``
- ``NPSCollectionQuery``
- ``NPSCollectionResolution``
- ``NPSDataRequest``
- ``NPSIdentifier``
- ``NPSPaginationError``
- ``NPSQueryItem``
- ``NPSSort``

### Parks

- ``Park``
- ``ParkCode``
- ``ParkQuery``
- ``StateCode``

### Shared park and facility details

- ``NPSAddress``
- ``NPSConstraintsInfo``
- ``NPSContacts``
- ``NPSEmailAddress``
- ``NPSFee``
- ``NPSImage``
- ``NPSImageCrop``
- ``NPSMultimedia``
- ``NPSNamedItem``
- ``NPSOperatingHours``
- ``NPSOperatingHoursException``
- ``NPSPhoneNumber``
- ``NPSQuickFact``
- ``NPSRelatedOrganization``
- ``NPSRelatedPark``

### Things to Do

- ``ThingToDo``
- ``ThingToDoQuery``

### Visitor Centers

- ``VisitorCenter``
- ``VisitorCenterQuery``
