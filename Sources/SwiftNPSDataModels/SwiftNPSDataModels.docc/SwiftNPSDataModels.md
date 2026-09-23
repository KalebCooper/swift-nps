# ``SwiftNPSDataModels``

Typed NPS collection responses, queries, and requests without a networking dependency.

## Overview

This module describes National Park Service Data API operations as values. Activities, activity
parks, alerts, amenities, articles, campgrounds, lesson plans, news releases, park audio, park
boundaries, park fees and passes, park videos, parking lots, parks, passport stamp locations,
people, photo galleries, photo gallery assets, places, road events, things to do, topic parks,
topics, tours, visitor centers, and webcams are the implemented endpoint groups. Every
offset-paginated one is built on a shared core: a validated ``NPSCollectionQuery``, the
``NPSCollection`` envelope, typed ``Endpoint`` values, and the reusable ``NPSDataRequest``. Park
boundaries and road events are single responses with no pagination. Construction performs no I/O,
and this module never imports a transport or holds credentials.

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
`passportStampImages`, `/thingstodo` and `/people` send a string, `/people` as `"0.8"` or `"1"`, and
one `/places` response mixes both, text under `images` and a number under `passportStampImages`; a
string is stored exactly as sent and a number as its decimal text, with ``NPSImageCrop/ratio``
parsing it when numeric.
``NPSRelatedPark`` is the park summary attached to records from other groups, with `states` kept
as the provider's comma-joined text. ``NPSQuickFact`` is the labeled fact ``Place`` and ``Person``
declare, and ``NPSRelatedOrganization`` is the linked organization ``Place``, ``Person``, and
``NewsRelease`` declare, both kept as the provider sends them.
``NPSConstraintsInfo`` is the rights and usage constraint text ``PhotoGallery`` and
``PhotoGalleryAsset`` carry, kept as open strings.

### Activities

``ParkActivityQuery`` describes all six activities parameters: activity identifiers, park codes,
text search, sort criteria, page limit, and start offset. The live service sorts by `name`,
ascending or descending, and answers another field such as `fullName`, `parkCode`, or
`relevanceScore` with HTTP 400; sort fields are still sent without validation. It ignores
`stateCode`, so the query has none, and it ignores an identifier it does not recognize rather
than matching nothing. Empty identifier, code, and sort arrays omit the parameter, and search text
is preserved and percent encoded, including empty text. Activities pages are
`NPSCollection<ParkActivity>`, from ``Endpoint/parkActivities(query:)`` or
``NPSDataRequest/parkActivities(query:)``.

``ParkActivity`` requires only an identifier and a name. It keeps its own type rather than reusing
``NPSNamedItem`` because activities are an independent taxonomy the provider can extend on its
own schedule, and a caller should see what the collection holds. Unlike ``ParkActivityParks``, a
page of activities carries no nested parks.

Real responses were recorded on September 22, 2026.

### Activity Parks

``ParkActivityParksQuery`` describes all six activity parks parameters: activity identifiers, park
codes, text search, sort criteria, page limit, and start offset. The live service sorts by `name`,
ascending or descending, and answers another field such as `fullName`, `parkCode`, or
`relevanceScore` with HTTP 400; sort fields are still sent without validation. It ignores
`stateCode`, so the query has none, and it ignores an identifier it does not recognize rather
than matching nothing. Empty identifier, code, and sort arrays omit the parameter, and search text
is preserved and percent encoded, including empty text. Activity parks pages are
`NPSCollection<ParkActivityParks>`, from ``Endpoint/parkActivityParks(query:)`` or
``NPSDataRequest/parkActivityParks(query:)``.

``ParkActivityParks`` requires an identifier and a name, and lists the parks offering that activity
as ``NPSRelatedPark`` values in ``ParkActivityParks/parks``, optional and in provider order. Unlike
the amenity park endpoints, each page's `data` is a plain array of activities rather than
per-group arrays, so pages iterate as ordinary items. Park codes both select the activities
offered at those parks and narrow each activity's `parks` to the requested parks; without them,
one activity can list more than a hundred parks.

Real responses were recorded on September 22, 2026.

### Alerts

``ParkAlertQuery`` describes all five documented alerts parameters: park codes, state codes, text
search, page limit, and start offset. NPS documents no alerts sort parameter, so the query has
none. Empty code arrays omit the filter, and search text is preserved and percent encoded,
including empty text. Alerts pages are `NPSCollection<ParkAlert>`, from
``Endpoint/parkAlerts(query:)`` or ``NPSDataRequest/parkAlerts(query:)``.

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
``Endpoint/articles(query:)`` or ``NPSDataRequest/articles(query:)``. The live service answers
`sort=title` with HTTP 400 and an empty envelope, so this query has no sort parameter.

``Article`` requires an identifier and title; other documented fields remain optional, and unknown
JSON fields are ignored. ``Article/latitude`` and ``Article/longitude`` are JSON numbers or `null`,
and most articles send `null`. ``Article/latLong`` is the provider's own coordinate text, such as
`"{lat:31.976943969726562, long:-104.75194549560547}"` or an empty string, kept without parsing or
cross-checking.
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

### Lesson Plans

``LessonPlanQuery`` describes all seven lesson plans parameters: identifiers, park codes, state
codes, text search, sort criteria, page limit, and start offset. The live service sorts by
`title`, ascending or descending, and ignores an identifier it does not recognize rather than
matching nothing; sort fields are still sent without validation. Park codes select the lesson
plans related to those parks without narrowing each plan's ``LessonPlan/parks``, unlike activity
and topic parks. Empty identifier, code, and sort arrays omit the parameter, and search text is
preserved and percent encoded, including empty text. Lesson plans pages are
`NPSCollection<LessonPlan>`, from ``Endpoint/lessonPlans(query:)`` or
``NPSDataRequest/lessonPlans(query:)``.

``LessonPlan`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. ``LessonPlan/subjects`` decodes from the wire `subject` key, the
same rename pattern as fees and passes' `image` to `images`. ``LessonPlan/parks`` holds plain park
code strings rather than park objects. ``LessonPlan/gradeLevel`` and ``LessonPlan/duration`` are
the provider's descriptive text, such as `"Middle School: Sixth Grade through Eighth Grade"` and
`"90 Minutes"`; neither is parsed. ``LessonPlan/CommonCore`` keeps its education standard fields
open text: ``LessonPlan/CommonCore/elaStandards`` and ``LessonPlan/CommonCore/mathStandards`` hold
codes such as `"6-8.RH.7"`, and ``LessonPlan/CommonCore/stateStandards`` and
``LessonPlan/CommonCore/additionalStandards`` are free text, both often empty.

Real responses were recorded on September 22, 2026.

### News Releases

``NewsReleaseQuery`` describes all six news releases parameters: park codes, state codes, text
search, sort criteria, page limit, and start offset. The live service sorts by `releaseDate` and
`title`, with a leading minus for descending order, and answers another field such as
`relevanceScore` with HTTP 400; sort fields are still sent without validation. Empty code and sort
arrays omit the parameter, and search text is preserved and percent encoded, including empty text.
News releases pages are `NPSCollection<NewsRelease>`, from ``Endpoint/newsReleases(query:)`` or
``NPSDataRequest/newsReleases(query:)``.

``NewsRelease`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. The summary is ``NewsRelease/abstract``.
``NewsRelease/releaseDate`` and ``NewsRelease/lastIndexedDate`` are the provider's text, such as
`"2026-09-17 15:34:00.0"`, which is not ISO 8601 and names no time zone, so no date is derived.
``NewsRelease/parkCode`` is the provider's text, which can be one code, a comma-separated list such
as `"anac,nace"`, or an empty string. ``NewsRelease/image`` is one shared ``NPSImage`` with no
crops, and can arrive with every field empty. Parks are ``NPSRelatedPark`` values and organizations
are ``NPSRelatedOrganization`` values, either of which can be an empty array.
``NewsRelease/latitude`` and ``NewsRelease/longitude`` are JSON numbers or `null`; every recorded
release sends `null`.

Real responses were recorded on September 21, 2026.

### Park Audio

``ParkAudioQuery`` describes all six park audio parameters: park codes, state codes, text search,
sort criteria, page limit, and start offset. The live service sorts by `title`, with a leading
minus for descending order, and answers another field such as `relevanceScore` with HTTP 400;
sort fields are still sent without validation. Empty code and sort arrays omit the parameter, and
search text is preserved and percent encoded, including empty text. Park audio pages are
`NPSCollection<ParkAudio>`, from ``Endpoint/parkAudio(query:)`` or
``NPSDataRequest/parkAudio(query:)``.

``ParkAudio`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. ``ParkAudio/transcript`` is the provider's plain text or HTML,
kept as sent. ``ParkAudio/splashImage`` is one shared ``NPSImage`` carrying only its URL text,
which is often empty. ``ParkAudio/durationMs`` is a JSON integer or `null`, and
``ParkAudio/latitude`` and ``ParkAudio/longitude`` are JSON numbers or `null`. Each
``ParkAudio/Version`` is one downloadable file whose ``ParkAudio/Version/fileSize`` keeps the
provider's number, such as `170844.0`, and can be `0.0`; NPS documents no unit for it.
``ParkAudio/permalinkUrl`` is the provider's web page link, kept as sent. Parks are
``NPSRelatedPark`` values.

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

### Park Fees and Passes

``ParkFeesAndPassesQuery`` describes all six fees and passes parameters: park codes, state codes,
text search, sort criteria, page limit, and start offset. The live service sorts by `parkCode` and
`fullName`, ascending or descending, and answers another field such as `name`, `relevanceScore`,
or `isFeeFreePark` with HTTP 400; sort fields are still sent without validation. Empty code and
sort arrays omit the parameter, and search text is preserved and percent encoded, including empty
text. Fees and passes pages are `NPSCollection<ParkFeesAndPasses>`, from
``Endpoint/parkFeesAndPasses(query:)`` or ``NPSDataRequest/parkFeesAndPasses(query:)``.

``ParkFeesAndPasses`` requires a park code and otherwise reports one record per park; other
documented fields remain optional, and unknown JSON fields are ignored. The four `is` flags are
the provider's JSON Booleans. ``ParkFeesAndPasses/fees`` and ``ParkFeesAndPasses/passes`` cover a
park's own entrance fees and annual passes, and ``ParkFeesAndPasses/relatedMultiSitePasses`` covers
passes sold across several parks, such as the Hawai'i Tri-Park Annual Pass. Every
``ParkFeesAndPasses/Fee/cost``, ``ParkFeesAndPasses/Pass/cost``, and
``ParkFeesAndPasses/MultiSitePass/cost`` is the provider's text, such as `"55.00"`; NPS documents
no currency or unit for it. On both ``ParkFeesAndPasses/Pass`` and
``ParkFeesAndPasses/MultiSitePass``, the Swift property is `images`, decoded from the provider's
`image` key, which holds an array; pass images carry attribution, text, and URL fields but no crops,
and every recorded multi-site pass sends that array empty.

``ParkFeesAndPasses/SeasonDate`` stores a fee's season boundary exactly as sent:
``ParkFeesAndPasses/SeasonDate/day``, ``ParkFeesAndPasses/SeasonDate/holiday``, and
``ParkFeesAndPasses/SeasonDate/month``. Most dates carry a month and day; some carry only a
holiday name, such as `"Memorial Day"`, with a null day and month, because a floating holiday
falls on a different date each year and cannot be derived from its name. A few dates carry all
three fields. ``ParkFeesAndPasses/SeasonDate/dateComponents`` returns the month and day when both
are present and nil otherwise, including for a holiday-only date.
``ParkFeesAndPasses/SeasonDate/date(in:calendar:)`` takes the caller's own calendar, since no time
zone is defaulted, and returns nil for a holiday-only date and for an impossible day such as
February 30 rather than rolling into the next month.

Real responses were recorded on September 22, 2026.

### Park Videos

``ParkVideoQuery`` describes all six park video parameters: park codes, state codes, text search,
sort criteria, page limit, and start offset. The live service sorts by `title`, with a leading
minus for descending order, and answers another field such as `relevanceScore` with HTTP 400;
sort fields are still sent without validation. Empty code and sort arrays omit the parameter, and
search text is preserved and percent encoded, including empty text. Park video pages are
`NPSCollection<ParkVideo>`, from ``Endpoint/parkVideos(query:)`` or
``NPSDataRequest/parkVideos(query:)``.

``ParkVideo`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. ``ParkVideo/audioDescribedBuiltIn``,
``ParkVideo/hasOpenCaptions``, ``ParkVideo/isBRoll``, and ``ParkVideo/isVideoOnly`` are the
provider's JSON Booleans. Each ``ParkVideo/CaptionFile`` keeps its language text, such as
`english`, as an open string. Each ``ParkVideo/Version`` is one downloadable rendition with its
aspect ratio, pixel dimensions, and a ``ParkVideo/Version/fileSizeKb`` that keeps the provider's
number, such as `15976.0`, or `null`; NPS documents no unit for it. Versions and caption files
can be empty arrays. ``ParkVideo/splashImage`` is one shared ``NPSImage`` carrying only its URL
text, which can be empty. ``ParkVideo/durationMs`` is a JSON integer or `null`, and
``ParkVideo/latitude`` and ``ParkVideo/longitude`` are JSON numbers or `null`. Parks are
``NPSRelatedPark`` values.

Real responses were recorded on September 21, 2026.

### Parking Lots

``ParkingLotQuery`` describes all six parking lots parameters: park codes, state codes, text
search, sort criteria, page limit, and start offset. The live service sorts by `name` and
`parkCode`, ascending or descending, and answers another field such as `title` or
`relevanceScore` with HTTP 400; sort fields are still sent without validation, and no default
order is documented. Empty code and sort arrays omit the parameter, and search text is preserved
and percent encoded, including empty text. Parking lot pages are `NPSCollection<ParkingLot>`,
from ``Endpoint/parkingLots(query:)`` or ``NPSDataRequest/parkingLots(query:)``.

``ParkingLot`` requires an identifier and name; other documented fields remain optional, and
unknown JSON fields are ignored. ``ParkingLot/Accessibility`` keeps the provider's `numberofAda`
keys, including the misspelled `numberofAdaVanAccessbileSpaces`, in conventionally spelled
properties. ``ParkingLot/LiveStatus`` is the provider's status report, which is stale and not
guaranteed to be current: ``ParkingLot/LiveStatus/occupancy`` and
``ParkingLot/LiveStatus/expirationDate`` are usually empty and are kept as sent.
``ParkingLot/latitude`` and ``ParkingLot/longitude`` are JSON numbers. Contacts, fees,
and operating hours reuse the shared ``NPSContacts``, ``NPSFee``, and ``NPSOperatingHours``
shapes. Parks are ``NPSRelatedPark`` values.

Real responses were recorded on September 21, 2026.

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

### Passport Stamp Locations

``PassportStampLocationQuery`` describes all seven passport stamp locations parameters: location
identifiers, park codes, state codes, text search, sort criteria, page limit, and start offset.
The live service orders by label for `name`, ascending or descending, and its default order
matches `name` ascending. It accepts `parkCode`, ascending or descending, with no observed
ordering, and answers `label`, `title`, `relevanceScore`, `fullName`, `type`, `id`, and unknown
fields with HTTP 400; sort fields are still sent without validation. It ignores an identifier it
does not recognize rather than matching nothing. Text search also matches text on a location's
related parks, not only its label. Empty identifier, code, and sort arrays omit the parameter,
and search text is preserved and percent encoded, including empty text. Passport stamp locations
pages are `NPSCollection<PassportStampLocation>`, from ``Endpoint/passportStampLocations(query:)``
or ``NPSDataRequest/passportStampLocations(query:)``.

``PassportStampLocation`` requires an identifier and a label. ``PassportStampLocation/type`` is
open text: a full scan observed only `visitorcenters`, `places`, and `campgrounds`, and other
values pass through unchanged. ``PassportStampLocation/parks`` lists ``NPSRelatedPark`` values,
optional and in provider order, and can be empty. Park codes select locations without narrowing
this array, so a location related to several parks keeps all of them. One recorded park's
`designation` ends with a carriage return and line feed.

Real responses were recorded on September 22, 2026.

### People

``PersonQuery`` describes all five people parameters: park codes, state codes, text search, page
limit, and start offset. Empty code arrays omit the filter, and search text is preserved and
percent encoded, including empty text. People pages are `NPSCollection<Person>`, from
``Endpoint/people(query:)`` or ``NPSDataRequest/people(query:)``. The live service answers
`sort=title` and `sort=lastName` with HTTP 400 and an empty envelope, so this query has no sort
parameter.

``Person`` requires an identifier and title; other documented fields remain optional, and unknown
JSON fields are ignored. ``Person/latitude``, ``Person/longitude``, and ``Person/latLong`` are
always JSON strings: an empty string for most people (338 of 500 in a live scan) and decimal text
such as `"42.32527319611405"` for the rest (162 of 500). They are kept as sent, not parsed into
numbers. ``Person/bodyText`` is the provider's HTML, unmodified. ``Person/quickFacts`` are
``NPSQuickFact`` values whose text, including dates, is not parsed; ``Person/relatedOrganizations``
are ``NPSRelatedOrganization`` values. Images are shared ``NPSImage`` values, and their crops send
`aspectRatio` as a string, such as `"0.8"`.

Real responses were recorded on September 21, 2026.

### Photo Galleries

``PhotoGalleryQuery`` describes all six photo gallery parameters: park codes, state codes, text
search, sort criteria, page limit, and start offset. The live service sorts by `title`, with a
leading minus for descending order, and answers another field such as `relevanceScore` with HTTP
400; sort fields are still sent without validation. Empty code and sort arrays omit the
parameter, and search text is preserved and percent encoded, including empty text. Photo gallery
pages are `NPSCollection<PhotoGallery>`, from ``Endpoint/photoGalleries(query:)`` or
``NPSDataRequest/photoGalleries(query:)``.

``PhotoGallery`` requires an identifier and title; other documented fields remain optional, and
unknown JSON fields are ignored. ``PhotoGallery/images`` holds the provider's preview image, one
per gallery in every recording, as shared ``NPSImage`` values with no caption, credit, or crops.
``PhotoGallery/assetCount`` is the provider's count of the gallery's assets, a JSON integer.
``PhotoGallery/url`` is the gallery's web page, not an API endpoint.
``PhotoGallery/constraintsInfo`` is an ``NPSConstraintsInfo`` whose text, such as
`Public domain` and `Unknown`, is an open set kept as sent, and ``PhotoGallery/copyright`` is the
provider's copyright text. Tags are strings, and parks are ``NPSRelatedPark`` values; either can
be an empty array.

Real responses were recorded on September 21, 2026.

### Photo Gallery Assets

``PhotoGalleryAssetQuery`` describes all eight photo gallery asset parameters: gallery
identifiers sent as `galleryId`, asset identifiers sent as `id`, park codes, state codes, text
search, sort criteria, page limit, and start offset. The live service sorts by `title`, with a
leading minus for descending order, and answers another field such as `relevanceScore` with HTTP
400; sort fields are still sent without validation. Empty identifier, code, and sort arrays omit
the parameter, and search text is preserved and percent encoded, including empty text. Photo
gallery asset pages are `NPSCollection<PhotoGalleryAsset>`, from
``Endpoint/photoGalleryAssets(query:)`` or ``NPSDataRequest/photoGalleryAssets(query:)``.

A `galleryId` of an uppercase gallery UUID returns exactly that gallery's assets, as many as its
``PhotoGallery/assetCount``, and a comma-separated list returns the sum. The service matches
case sensitively, so a lowercase UUID returns none, and an unknown UUID returns none. A value
that is not UUID-shaped, such as `zzzz`, is silently ignored, and every asset comes back. `id`
behaves the same way. The query validates neither.

``PhotoGalleryAsset`` requires an identifier and title; other documented fields remain optional,
and unknown JSON fields are ignored. The service returns one entry per gallery membership, so an
asset in several galleries repeats its ``PhotoGalleryAsset/id`` with a different
``PhotoGalleryAsset/ordinal`` and ``PhotoGalleryAsset/permalinkUrl``; the entry has no gallery
identifier field, and only the permalink names the gallery. ``PhotoGalleryAsset/fileInfo`` is a
``PhotoGalleryAsset/FileInfo`` with the file URL, media type, pixel dimensions, and
``PhotoGalleryAsset/FileInfo/fileSizeKb``, the provider's number, such as `11170890` for a 6000 by
4000 pixel `image/jpeg`, for which NPS documents no unit. ``PhotoGalleryAsset/constraintsInfo`` is
an ``NPSConstraintsInfo`` of open text, and ``PhotoGalleryAsset/copyright`` is the provider's
copyright text, which varies by asset and is kept as sent, including mis-encoded characters.
Tags are strings, and parks are ``NPSRelatedPark`` values; either can be an empty array.

Real responses were recorded on September 21, 2026.

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

### Topic Parks

``ParkTopicParksQuery`` describes all six topic parks parameters: topic identifiers, park codes,
text search, sort criteria, page limit, and start offset. The live service sorts by `name`,
ascending or descending, and answers another field such as `fullName`, `parkCode`, or
`relevanceScore` with HTTP 400; sort fields are still sent without validation. It ignores
`stateCode`, so the query has none, and it ignores an identifier it does not recognize rather than
matching nothing. Empty identifier, code, and sort arrays omit the parameter, and search text is
preserved and percent encoded, including empty text. Topic parks pages are
`NPSCollection<ParkTopicParks>`, from ``Endpoint/parkTopicParks(query:)`` or
``NPSDataRequest/parkTopicParks(query:)``.

``ParkTopicParks`` requires an identifier and a name, and lists the parks associated with that topic
as ``NPSRelatedPark`` values in ``ParkTopicParks/parks``, optional and in provider order. Each
page's `data` is a plain array of topics, so pages iterate as ordinary items. Park codes both select
the topics associated with those parks and narrow each topic's `parks` to the requested parks;
without them, one topic can list more than a hundred parks. Park fields keep the provider's text as
sent: one recorded park's `designation` ends with a carriage return and line feed.

Real responses were recorded on September 22, 2026.

### Topics

``ParkTopicQuery`` describes all six topics parameters: topic identifiers, park codes, text search,
sort criteria, page limit, and start offset. The live service sorts by `name`, ascending or
descending, and answers another field such as `fullName`, `parkCode`, or `relevanceScore` with
HTTP 400; sort fields are still sent without validation. It ignores `stateCode`, so the query has
none, and it ignores an identifier it does not recognize rather than matching nothing. Empty
identifier, code, and sort arrays omit the parameter, and search text is preserved and percent
encoded, including empty text. Topics pages are `NPSCollection<ParkTopic>`, from
``Endpoint/parkTopics(query:)`` or ``NPSDataRequest/parkTopics(query:)``.

``ParkTopic`` requires only an identifier and a name. It keeps its own type rather than reusing
``NPSNamedItem`` because topics are an independent taxonomy the provider can extend on its own
schedule, and a caller should see what the collection holds. Unlike ``ParkTopicParks``, a page of
topics carries no nested parks.

Real responses were recorded on September 22, 2026.

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

### Activities

- ``ParkActivity``
- ``ParkActivityQuery``

### Activity Parks

- ``ParkActivityParks``
- ``ParkActivityParksQuery``

### Alerts

- ``ParkAlertQuery``
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

### Lesson Plans

- ``LessonPlan``
- ``LessonPlanQuery``

### News Releases

- ``NewsRelease``
- ``NewsReleaseQuery``

### Park Audio

- ``ParkAudio``
- ``ParkAudioQuery``

### Park Boundaries

- ``NPSCoordinateTree``
- ``NPSGeometry``
- ``ParkBoundary``
- ``ParkBoundaryDetails``
- ``ParkBoundaryFeature``

### Park Fees and Passes

- ``ParkFeesAndPasses``
- ``ParkFeesAndPassesQuery``

### Park Videos

- ``ParkVideo``
- ``ParkVideoQuery``

### Parking Lots

- ``ParkingLot``
- ``ParkingLotQuery``

### Parks

- ``Park``
- ``ParkCode``
- ``ParkQuery``
- ``StateCode``

### Passport Stamp Locations

- ``PassportStampLocation``
- ``PassportStampLocationQuery``

### People

- ``Person``
- ``PersonQuery``

### Photo Galleries

- ``PhotoGallery``
- ``PhotoGalleryQuery``

### Photo Gallery Assets

- ``PhotoGalleryAsset``
- ``PhotoGalleryAssetQuery``

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

### Things to Do

- ``ThingToDo``
- ``ThingToDoQuery``

### Topic Parks

- ``ParkTopicParks``
- ``ParkTopicParksQuery``

### Topics

- ``ParkTopic``
- ``ParkTopicQuery``

### Tours

- ``Tour``
- ``TourQuery``

### Visitor Centers

- ``VisitorCenter``
- ``VisitorCenterQuery``

### Webcams

- ``Webcam``
- ``WebcamQuery``
