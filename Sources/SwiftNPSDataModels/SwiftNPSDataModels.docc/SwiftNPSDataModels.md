# ``SwiftNPSDataModels``

Typed NPS collection responses, queries, and requests without a networking dependency.

## Overview

This module describes National Park Service Data API operations as values. Alerts, amenities,
articles, campgrounds, news releases, park boundaries, parks, places, road events, things to do,
tours, visitor centers, and webcams are the implemented endpoint groups. Every offset-paginated one is built on a shared
core: a validated ``NPSCollectionQuery``, the ``NPSCollection`` envelope, typed ``Endpoint``
values, and the reusable ``NPSDataRequest``. Park boundaries and road events are single responses
with no pagination. Construction performs no I/O, and this module never imports a transport or
holds credentials.

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
number on some paths and a JSON string on others: `/tours` sends the number under `images`,
`/campgrounds` and `/visitorcenters` send empty `images` crops and the number under
`passportStampImages`, `/thingstodo` sends a string, and one `/places` response mixes both, text
under `images` and a number under `passportStampImages`; a string is stored exactly as sent and a
number as its decimal text, with ``NPSImageCrop/ratio`` parsing it when numeric.
``NPSRelatedPark`` is the park summary attached to records from other groups, with `states` kept
as the provider's comma-joined text. ``NPSQuickFact`` and ``NPSRelatedOrganization`` are the
labeled facts and linked organizations ``Place`` declares, kept as the provider sends them.

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
``AmenityParkPlaces/PlaceSummary`` or ``AmenityParkVisitorCenters/VisitorCenterSummary`` values,
read from the lowercase `visitorcenters` key. Places and visitor center summaries carry links, so
they are not ``NPSNamedItem``. Unknown JSON fields are ignored.

The specification and real responses were checked on September 17, 2026. The live responses carry
`categories` on amenities and the extra group array on the park endpoints, and the models follow
them.

### Articles

``ArticleQuery`` describes all five articles parameters: park codes, state codes, text search, page
limit, and start offset. Empty code arrays omit the filter, and search text is preserved and
percent encoded, including empty text. Articles pages are `NPSCollection<Article>`, from
``Endpoint/articles(query:)`` or ``NPSDataRequest/articles(query:)``. The live service answers a
`sort` value with HTTP 400 and an empty envelope, so this query has no sort parameter at all.

``Article`` requires an identifier and title; other documented fields remain optional, and unknown
JSON fields are ignored. ``Article/latitude`` and ``Article/longitude`` are JSON numbers or `null`,
and most articles send `null`. ``Article/latLong`` is the provider's own coordinate text, such as
`"{lat:31.97, long:-104.75}"` or an empty string, kept without parsing or cross-checking.
``Article/listingImage`` is one shared ``NPSImage``; no recorded article image carries crops, so
its ``NPSImage/crops`` is nil. Parks are ``NPSRelatedPark`` values in ``Article/relatedParks``, and
tags are plain strings in provider order.

Real responses were recorded on September 21, 2026.

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
images are both ``NPSImage``, the same as visitor centers. Every recorded `images` crop array is
empty, and the numeric aspect ratio arrives under `passportStampImages`, stored as text.
``Campground/Accessibility``, ``Campground/Amenities``, and ``Campground/Campsites`` keep every
value as sent: flags such as `rvAllowed` stay `"0"` or `"1"`, lengths and site counts stay text,
and amenity descriptions such as `"Yes - seasonal"` stay open strings. The provider's lowercase
`regulationsurl` key decodes as ``Campground/regulationsUrl``.

Site counts, fees, and reservation links are published descriptions, not live campsite
availability or a booking service. The specification and real responses were checked on
September 17, 2026. The specification spells nested keys in lowercase, names the reservation
fields differently, and declares fees, images, and operating hours as arrays of strings; the live
responses send camelCase keys and objects, and add passport stamp fields, which the model follows.

### News Releases

``NewsReleaseQuery`` describes all six news releases parameters: park codes, state codes, text
search, sort criteria, page limit, and start offset. The live service sorts by `releaseDate` and
`title`, with a leading minus for descending order, and answers another field such as
`relevanceScore` with HTTP 400; sort fields are still sent without validation. Empty code and sort
arrays omit the parameter, and search text is preserved and percent encoded, including empty text.
News releases pages are `NPSCollection<NewsRelease>`, from ``Endpoint/newsReleases(query:)`` or
``NPSDataRequest/newsReleases(query:)``.

``NewsRelease`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. The summary is ``NewsRelease/abstract``. ``NewsRelease/releaseDate``
and ``NewsRelease/lastIndexedDate`` are the provider's text, such as `"2026-09-17 15:34:00.0"`,
which is not ISO 8601 and names no time zone, so no date is derived. ``NewsRelease/parkCode`` is
the provider's text, which can be one code, a comma-separated list such as `"anac,nace"`, or an
empty string. ``NewsRelease/image`` is one shared ``NPSImage`` with no crops, and can arrive with
every field empty. Parks are ``NPSRelatedPark`` values and organizations are
``NPSRelatedOrganization`` values, either of which can be an empty array.
``NewsRelease/latitude`` and ``NewsRelease/longitude`` are JSON numbers or `null`; every recorded
release sends `null`.

Real responses were recorded on September 21, 2026.

### Park Boundaries

``Endpoint/parkBoundary(parkCode:)`` and ``NPSDataRequest/parkBoundary(parkCode:)`` describe
`/mapdata/parkboundaries/{sitecode}`, which takes the park code as a path segment and no query
parameters and returns a bare GeoJSON feature collection, decoded as one ``ParkBoundary`` with no
pagination. Every recorded park returned exactly one ``ParkBoundaryFeature``. An unknown park code
returns HTTP 404 with an `application/problem+json` body, not the NPS error envelope.

Geometry is usually a `MultiPolygon` nested four levels deep: the recorded Dry Tortugas boundary
sends 2 polygons, and a live probe of Acadia returned 51. It is occasionally a `Polygon` nested
three deep, as the recorded Yellowstone boundary sends. ``NPSGeometry``
therefore keeps its coordinates as an ``NPSCoordinateTree`` of any depth, so a geometry kind this
package does not name keeps every coordinate, and offers ``NPSGeometry/polygon`` and
``NPSGeometry/multiPolygon`` as typed arrays. Each returns nil rather than trapping when the
declared type or the nesting depth does not match. Positions stay GeoJSON `[longitude, latitude]`
arrays as sent, whatever their length.

``ParkBoundaryDetails`` carries the park's names, ``ParkBoundaryDetails/Alias`` entries such as the
uppercase park code, and a ``ParkBoundaryDetails/Designation`` object; it is not the park summary
shape other groups attach. ``ParkBoundaryFeature/id`` matched the park's identifier in the
recordings, which is an observation, not a guarantee. Boundary geometry is published cartographic
data, not a survey or a legal record.

Real responses were recorded on September 20, 2026.

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

### Places

``PlaceQuery`` describes all five documented places parameters: park codes, state codes, text
search, page limit, and start offset. Empty code arrays omit the filter, and search text is
preserved and percent encoded, including empty text. Places pages are `NPSCollection<Place>`, from
``Endpoint/places(query:)`` or ``NPSDataRequest/places(query:)``. The live service answers every
`sort` value with HTTP 400 and an empty envelope, so this query has no sort parameter at all.

``Place`` requires an identifier and title; other documented fields remain optional, and unknown
JSON fields are ignored. The provider publishes three coordinate representations in one item,
``Place/latitude``, ``Place/longitude``, and ``Place/latLong``, and each keeps its own text without
parsing or cross-checking. Flags such as ``Place/isOpenToPublic``, ``Place/isMapPinHidden``,
``Place/isManagedByNps``, and ``Place/isPassportStampLocation`` stay the provider's `"0"` or `"1"`
text; a place can publish ``Place/passportStampImages`` while sending `"0"` for
``Place/isPassportStampLocation``, so the two are independent values. ``Place/bodyText`` and
``Place/audioDescription`` carry HTML, ``Place/relevanceScore`` is a real number, and
``Place/amenities`` and ``Place/tags`` are plain strings in provider order. Quick facts are
``NPSQuickFact``, related organizations ``NPSRelatedOrganization``, and related parks
``NPSRelatedPark`` summaries.

Images are the shared ``NPSImage``. One places response mixes both crop forms: ``Place/images``
crops send the aspect ratio as text such as `"1.78"`, while ``Place/passportStampImages`` crops
send it as a JSON number. ``NPSImageCrop`` stores either form as text and derives
``NPSImageCrop/ratio`` from it.

Real responses were recorded on September 20, 2026, and every sort value tried against the live
endpoint answered HTTP 400.

### Road Events

``Endpoint/roadEvents(parkCode:type:)`` and ``NPSDataRequest/roadEvents(parkCode:type:)`` describe
`/roadevents`, which returns a WZDx 4.1 GeoJSON feed rather than the paged envelope, decoded as one
``RoadEventFeed`` with no pagination. Omitted parameters are not sent. ``RoadEventType`` is a closed
set because the provider answers any other value with HTTP 400, and each case sends the provider's
own spelling: the provider rejects the WZDx spelling `work-zone` and accepts `WorkZone`. A valid
type with no matching events returns an empty feed rather than an error. The provider silently
ignores a park code it does not recognize, including a comma-separated list, and returns every
park's events, while a recognized code with no events returns an empty feed, which is what most
parks return.

Keys are remapped from the provider's snake_case, and every value is kept as sent: timestamps stay
text, vocabulary such as ``RoadEventDetails/CoreDetails/eventType`` stays an open string in WZDx
spelling, and ``RoadEventFeature/geometry`` is the shared ``NPSGeometry``, whose GeoJSON
`[longitude, latitude]` positions are read through ``NPSGeometry/lineString``. Every recorded
feature is a `LineString`; one sent at another depth keeps its coordinates rather than failing the
feed.
``RoadEventDetails`` preserves both identifiers the provider sends, `Id` as
``RoadEventDetails/id`` and `_id` as ``RoadEventDetails/numericId``. Incidents carry
``RoadEventDetails/typesOfIncident`` and work zones ``RoadEventDetails/typesOfWork``, neither
guaranteed. The feed is published by the National Park Service, named in
``RoadEventFeedInfo/publisher``, under the license URL in ``RoadEventFeedInfo/license``, which this
package's license does not cover. It is not an authoritative live closure service.

Real responses were recorded on September 20, 2026.

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

### Tours

``TourQuery`` describes all seven tours parameters: identifiers, park codes, state codes, text
search, sort criteria, page limit, and start offset. Identifiers are ``NPSIdentifier`` values sent
as `id`. Empty identifier, code, and sort arrays omit the parameter, and search text is preserved
and percent encoded, including empty text. Tours pages are `NPSCollection<Tour>`, from
``Endpoint/tours(query:)`` or ``NPSDataRequest/tours(query:)``. `relevanceScore` is the only sort
field the live service accepts; it answers other fields with HTTP 400. Sort fields are sent without
validation, so that failure comes from NPS rather than the query.

``Tour`` requires an identifier and title; other documented fields remain optional, and unknown
JSON fields are ignored. A tour links one park through ``Tour/park``, a single ``NPSRelatedPark``
rather than the array other groups send. ``Tour/durationMin`` and ``Tour/durationMax`` stay the
provider's numeric text, measured in the separate ``Tour/durationUnit`` code such as `"m"`, `"h"`,
or `"d"`, and nothing is converted to a duration. Activities and topics are ``NPSNamedItem``.
Stops are ``Tour/Stop`` values in provider order: ``Tour/Stop/ordinal`` is text such as `"1"`,
``Tour/Stop/assetType`` names the collection its ``Tour/Stop/assetId`` belongs to, such as
`"places"` or `"visitorcenters"`, and every stop field is optional and keeps empty strings as sent.

Images are the shared ``NPSImage``, without a description on this path. Tours crops send the aspect
ratio as a JSON number, the opposite of places images, and ``NPSImageCrop`` stores it as its
decimal text, so `1.78` becomes `"1.78"` with ``NPSImageCrop/ratio`` `1.78`.

Real responses were recorded on September 20, 2026.

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

### Webcams

``WebcamQuery`` describes all six webcams parameters: identifiers, park codes, state codes, text
search, page limit, and start offset. Identifiers are ``NPSIdentifier`` values sent as `id`. Empty
identifier and code arrays omit the parameter, and search text is preserved and percent encoded,
including empty text. Webcams pages are `NPSCollection<Webcam>`, from ``Endpoint/webcams(query:)``
or ``NPSDataRequest/webcams(query:)``. The live endpoint answers every sort value with HTTP 400, so
the query has no sort parameter.

``Webcam`` requires an identifier and title; other documented fields remain optional, and unknown
JSON fields are ignored. Each field keeps the provider's own JSON type. ``Webcam/isStreaming`` is a
JSON Boolean, unlike the `"0"` and `"1"` text flags places send. ``Webcam/latitude`` and
``Webcam/longitude`` are JSON numbers or `null`, unlike the coordinate text places send; no shared
coordinate type exists. The API does not guarantee a per-camera location: both recorded Grand Teton
cameras send `null`, and a live probe found cameras in one park sharing one coordinate. Whatever
arrives is kept as sent. ``Webcam/status`` is open text such as
`"Active"` or `"Inactive"`. Parks are ``NPSRelatedPark`` values in ``Webcam/relatedParks``, tags
are strings, and images are the shared ``NPSImage`` with its URL text kept exactly as sent.

Real responses were recorded on September 20, 2026.

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

### Articles

- ``Article``
- ``ArticleQuery``

### Campgrounds

- ``Campground``
- ``CampgroundQuery``

### Collections

- ``NPSCollection``
- ``NPSCollectionQuery``
- ``NPSCollectionResolution``
- ``NPSDataRequest``
- ``NPSIdentifier``
- ``NPSPaginationError``
- ``NPSQueryItem``
- ``NPSSort``

### Endpoints and errors

- ``Endpoint``
- ``ServiceErrorResponse``

### News Releases

- ``NewsRelease``
- ``NewsReleaseQuery``

### Park Boundaries

- ``NPSCoordinateTree``
- ``NPSGeometry``
- ``ParkBoundary``
- ``ParkBoundaryDetails``
- ``ParkBoundaryFeature``

### Parks

- ``Park``
- ``ParkCode``
- ``ParkQuery``
- ``StateCode``

### Places

- ``Place``
- ``PlaceQuery``

### Road Events

- ``RoadEventDataSource``
- ``RoadEventDetails``
- ``RoadEventFeature``
- ``RoadEventFeed``
- ``RoadEventFeedInfo``
- ``RoadEventType``

### Shared park and facility details

- ``NPSAddress``
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

### Tours

- ``Tour``
- ``TourQuery``

### Visitor Centers

- ``VisitorCenter``
- ``VisitorCenterQuery``

### Webcams

- ``Webcam``
- ``WebcamQuery``
