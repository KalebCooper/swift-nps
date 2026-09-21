# Recorded responses

Recorded from the NPS Data API on September 13, 2026 (parks and the missing key) and September 17,
2026 (alerts, amenities, campgrounds, things to do, and visitor centers), and September 20, 2026
(park boundaries, places, road events, tours, and webcams) using the application identity
`(swift-nps, https://github.com/KalebCooper/swift-nps)`. These are real response bodies,
not examples copied from the specification. Tests read them locally and never contact NPS.

| File | Exact request | HTTP status |
| --- | --- | --- |
| alerts-empty.json | GET https://developer.nps.gov/api/v1/alerts?limit=1&parkCode=zzzz&start=0 | 200 |
| alerts-page-first.json | GET https://developer.nps.gov/api/v1/alerts?limit=1&parkCode=acad&start=0 | 200 |
| alerts-page-last.json | GET https://developer.nps.gov/api/v1/alerts?limit=1&parkCode=acad&start=1 | 200 |
| alerts-search.json | GET https://developer.nps.gov/api/v1/alerts?limit=2&parkCode=acad,yell&start=0 | 200 |
| amenities-empty.json | GET https://developer.nps.gov/api/v1/amenities?limit=1&q=zzzzzz&start=0 | 200 |
| amenities-page-first.json | GET https://developer.nps.gov/api/v1/amenities?limit=1&start=0 | 200 |
| amenities-page-last.json | GET https://developer.nps.gov/api/v1/amenities?limit=1&start=1 | 200 |
| amenities-parksplaces-empty.json | GET https://developer.nps.gov/api/v1/amenities/parksplaces?limit=1&parkCode=zzzz&start=0 | 200 |
| amenities-parksplaces-page-first.json | GET https://developer.nps.gov/api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=0 | 200 |
| amenities-parksplaces-page-last.json | GET https://developer.nps.gov/api/v1/amenities/parksplaces?limit=1&parkCode=acad&start=1 | 200 |
| amenities-parksvisitorcenters-empty.json | GET https://developer.nps.gov/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=zzzz&start=0 | 200 |
| amenities-parksvisitorcenters-page-first.json | GET https://developer.nps.gov/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=0 | 200 |
| amenities-parksvisitorcenters-page-last.json | GET https://developer.nps.gov/api/v1/amenities/parksvisitorcenters?limit=1&parkCode=acad&start=1 | 200 |
| amenities-search.json | GET https://developer.nps.gov/api/v1/amenities?limit=2&q=restroom&start=0 | 200 |
| api-key-missing.json | GET https://developer.nps.gov/api/v1/parks?parkCode=acad&limit=1&start=0 without an API key | 403 |
| campgrounds-empty.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=1&parkCode=zzzz&start=0 | 200 |
| campgrounds-page-first.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=0 | 200 |
| campgrounds-page-last.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=1 | 200 |
| campgrounds-search.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=2&q=lake&sort=name&start=0&stateCode=WY | 200 |
| parkboundaries-drto.json | GET https://developer.nps.gov/api/v1/mapdata/parkboundaries/drto | 200 |
| parkboundaries-unknown.json | GET https://developer.nps.gov/api/v1/mapdata/parkboundaries/zzzz | 404 |
| parkboundaries-yell.json | GET https://developer.nps.gov/api/v1/mapdata/parkboundaries/yell | 200 |
| parks-acad.json | GET https://developer.nps.gov/api/v1/parks?parkCode=acad&limit=1&start=0 | 200 |
| parks-beyond.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=2 | 200 |
| parks-empty.json | GET https://developer.nps.gov/api/v1/parks?parkCode=zzzz&limit=1&start=0 | 200 |
| parks-page-first.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0 | 200 |
| parks-page-last.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=1 | 200 |
| parks-search.json | GET https://developer.nps.gov/api/v1/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA | 200 |
| parks-yell.json | GET https://developer.nps.gov/api/v1/parks?parkCode=yell&limit=1&start=0 | 200 |
| places-empty.json | GET https://developer.nps.gov/api/v1/places?limit=1&parkCode=zzzz&start=0 | 200 |
| places-page-first.json | GET https://developer.nps.gov/api/v1/places?limit=1&parkCode=acad&start=0 | 200 |
| places-page-last.json | GET https://developer.nps.gov/api/v1/places?limit=1&parkCode=acad&start=1 | 200 |
| places-search.json | GET https://developer.nps.gov/api/v1/places?limit=2&q=Redoubt&start=0&stateCode=FL | 200 |
| roadevents-dewa.json | GET https://developer.nps.gov/api/v1/roadevents?parkCode=dewa | 200 |
| roadevents-empty.json | GET https://developer.nps.gov/api/v1/roadevents?parkCode=acad | 200 |
| roadevents-type.json | GET https://developer.nps.gov/api/v1/roadevents?parkCode=yell&type=WorkZone | 200 |
| roadevents-yell.json | GET https://developer.nps.gov/api/v1/roadevents?parkCode=yell | 200 |
| thingstodo-empty.json | GET https://developer.nps.gov/api/v1/thingstodo?limit=1&parkCode=zzzz&start=0 | 200 |
| thingstodo-page-first.json | GET https://developer.nps.gov/api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0 | 200 |
| thingstodo-page-last.json | GET https://developer.nps.gov/api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=1 | 200 |
| thingstodo-search.json | GET https://developer.nps.gov/api/v1/thingstodo?limit=2&q=hike&sort=-relevanceScore&start=0&stateCode=ME | 200 |
| tours-empty.json | GET https://developer.nps.gov/api/v1/tours?limit=1&parkCode=zzzz&start=0 | 200 |
| tours-page-first.json | GET https://developer.nps.gov/api/v1/tours?limit=1&parkCode=cavo&start=0 | 200 |
| tours-page-last.json | GET https://developer.nps.gov/api/v1/tours?limit=1&parkCode=cavo&start=1 | 200 |
| tours-search.json | GET https://developer.nps.gov/api/v1/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1&limit=2&parkCode=foma&q=Virtual&sort=-relevanceScore&start=0&stateCode=FL | 200 |
| visitorcenters-empty.json | GET https://developer.nps.gov/api/v1/visitorcenters?limit=1&parkCode=zzzz&start=0 | 200 |
| visitorcenters-page-first.json | GET https://developer.nps.gov/api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=0 | 200 |
| visitorcenters-page-last.json | GET https://developer.nps.gov/api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=1 | 200 |
| visitorcenters-search.json | GET https://developer.nps.gov/api/v1/visitorcenters?limit=2&q=museum&sort=name&start=0&stateCode=ME,MA | 200 |
| webcams-empty.json | GET https://developer.nps.gov/api/v1/webcams?limit=1&parkCode=zzzz&start=0 | 200 |
| webcams-page-first.json | GET https://developer.nps.gov/api/v1/webcams?limit=1&parkCode=grte&start=0 | 200 |
| webcams-page-last.json | GET https://developer.nps.gov/api/v1/webcams?limit=1&parkCode=grte&start=1 | 200 |
| webcams-search.json | GET https://developer.nps.gov/api/v1/webcams?id=9849DE2B-BC23-1110-33CED7C04E8AAF05&limit=2&parkCode=gumo&q=Capitan&start=0&stateCode=TX | 200 |

Every successful recording sent its credential in the `X-Api-Key` header. The parks, alerts, and
visitor centers recordings used the service's public demonstration credential, which reported a
limit of 10. The campgrounds, things to do, and amenities recordings used the maintainer's private
key, which reported a limit of 1,000. No request headers or credentials are stored. The
missing-key recording deliberately omitted that header. Response ordering is retained, rather than
alphabetized, to preserve the provider's representation.

JSON whitespace is normalized to LF without trailing blanks. The Unicode em dash in Yellowstone
is written as the JSON escape `\u2014` to satisfy repository text rules. Decoded JSON was compared
with the original downloads and is identical. No data, nulls, fields, identifiers, or values were
invented or removed.

The alerts recordings arrived with CRLF line endings, blank lines, and trailing spaces. They are
reindented with two spaces and LF endings, keeping the provider's key order; they contain no
non-ASCII characters. Decoded values were compared with the downloads and are identical.

The visitor centers recordings arrived with CRLF line endings and are reindented the same way,
keeping the provider's key order and numeric literals such as `1.00`. Their two non-ASCII
characters, a right single quotation mark and an accented e, are written as the JSON escapes
`\u2019` and `\u00e9`. Decoded values were compared with the downloads and are identical.

The campgrounds recordings arrived with CRLF line endings, blank lines, and trailing spaces, and
are reindented the same way, keeping the provider's key order, escaped quotation marks, and numeric
literals such as `1.00`; they contain no non-ASCII characters. Decoded values were compared with
the downloads and are identical.

The things to do recordings arrived with CRLF line endings, blank lines, trailing spaces, and
commas leading each line, and are reindented the same way, keeping the provider's key order,
escaped quotation marks, and numeric literals. Their non-ASCII characters, no-break spaces and
curly quotation marks, are written as the JSON escapes `\u00a0`, `\u2019`, `\u201c`, and
`\u201d`. The empty recording is byte-identical to the other empty recordings. Decoded values
were compared with the downloads and are identical.

The amenities recordings arrived with CRLF line endings, blank lines, trailing spaces, and commas
leading each line, and are reindented the same way, keeping the provider's key order, including
the nested group arrays; they contain no non-ASCII characters or escapes. The three empty
recordings are byte-identical to the other empty recordings. Decoded values were compared with the
downloads and are identical. The park places and park visitor centers first pages were also
recorded a second time under a different name; those copies were byte-identical and are not kept.

The places recordings arrived with blank lines, trailing spaces, and commas leading each line, and
are reindented the same way, keeping the provider's key order, escaped quotation marks, and both
aspect ratio forms, the string `"1.78"` and the number `1.0`, in one body. Their non-ASCII
characters, no-break spaces, a degree sign, and curly quotation marks, are the provider's own bytes
and are left as sent; the one em dash the provider sends already arrives as the escape `\u2014`.
The empty recording is byte-identical to the other empty recordings. Decoded values were compared
with the downloads and are identical.

The tours recordings arrived with CRLF line endings, blank lines, and commas leading each line, and
are reindented the same way, keeping the provider's key order and the numeric aspect ratios `1.78`
and `1.0` as written. They are ASCII throughout and contain no escapes. The empty recording is
byte-identical to the other empty recordings. Decoded values were compared with the downloads and
are identical.

The road events recordings arrived as single-line JSON and are reindented the same way, keeping
the provider's key order, the escaped quotation marks in the Yellowstone descriptions, the escaped
line breaks in the Delaware Water Gap descriptions, and every coordinate as written. They are ASCII
throughout. The type-filtered recording is byte-identical to the unfiltered Yellowstone recording.
Decoded values were compared with the downloads and are identical.

The webcams recordings arrived with CRLF line endings, blank lines, and commas leading each line,
and are reindented the same way, keeping the provider's key order, the escaped quotation marks in
the search description, and the coordinates and `null` values as written. They are ASCII
throughout. The empty recording is byte-identical to the other empty recordings. Decoded values
were compared with the downloads and are identical.

The pagination and search recordings additionally escape non-ASCII characters using JSON Unicode
escapes. Their decoded values were compared with the downloads and are identical.

SHA-256 of the original downloaded bodies, before whitespace normalization and lossless escaping:

| File | SHA-256 |
| --- | --- |
| alerts-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| alerts-page-first.json | ddce89e0f28d5f35a164e9016bf155fbc1a6b686be4db49046d01f311812809f |
| alerts-page-last.json | 045c53d90dd590ac5a374b6fab43e821d8b1888810c94f472f0632935ba97f8c |
| alerts-search.json | abe1bba5228628b2e1471b66cc803ecf7809a6eafcef757a1b295d6d0f70fdcd |
| amenities-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| amenities-page-first.json | d6746d4717a3d1cada7607d712bdb2fd5adc8db2c3f36276cf90a729dd90704e |
| amenities-page-last.json | 540b507e72c7f0bb89c3a79dd11fbb9b6a1cb5e431ad3d5f0812ffad2f0910ef |
| amenities-parksplaces-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| amenities-parksplaces-page-first.json | 042083c785286f2df0bc5197f36335a34701d3a3b2380c379d3f1a50a0a98e29 |
| amenities-parksplaces-page-last.json | 30455e16d1aca75550916b1bd9a2eecb5d5cca8a663c52212e1cfd3b0f1d506e |
| amenities-parksvisitorcenters-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| amenities-parksvisitorcenters-page-first.json | 0cd194ff239193618fa1f13632bf2e8e0c934e1825ba50b6fc2958c729f7b9e6 |
| amenities-parksvisitorcenters-page-last.json | 06cec1916799d6bacad3b13991243a0f9613e8c504861e5c59c4da052be5e6f8 |
| amenities-search.json | f1308ec4cb3ab350a2277f0feb6c70f3528edfc16dd5bd6d00dd74adc8e74e62 |
| api-key-missing.json | adf24054a0da1d216699be8c128aa47c2c98f381a2c21945836ebc904653c8cc |
| campgrounds-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| campgrounds-page-first.json | 452d7fa85a1cd58f954961e3716b8c2075ad8bc9d4b13e1acaa58bb452251742 |
| campgrounds-page-last.json | 4778b70345af7bd999e4943e99dc43dfe227e9eba2fcef57b8dcebf3418aa104 |
| campgrounds-search.json | e1f09e544bd067518b0a5b8561c5f360d884818dcb0c0f12d7c1e291fa926f77 |
| parkboundaries-drto.json | 8c87bc141d6bdf4580cf166a902a2700ba810c8bd17327489e87d72a454c7885 |
| parkboundaries-unknown.json | c4e912cc04e9b3426cd17b27a5d01eba6442efc6fb3c5be30181679fb996330b |
| parkboundaries-yell.json | 96a49dd65006cfb7901a035ba26a6aa22d0bcfc70577f1aad25f36b1e03a70ed |
| parks-acad.json | 190b90f17bff221b71e564247b265a581844143b4eeca8455674ad47154f4632 |
| parks-beyond.json | bc6e94934ea41746830b8df13e264efc9eef42d9fe23ace5e61d81c6d728996d |
| parks-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| parks-page-first.json | bdf759dc187c206a91cb7b90ac5f667c2329de3734a4ede7bd20b37f1e82239d |
| parks-page-last.json | 76e1eeea6fde0f15c64aab4f073f068002f1dde043b332aa197725798da0f8d2 |
| parks-search.json | 1302400226103d947077e3d10908462b433ffc6b1e69511807af852640a67009 |
| parks-yell.json | 243bbc33c1ffee6ff2d86794e2b546d32da28c9a9f605449aa2e88968697b53d |
| places-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| places-page-first.json | 2d4185659bf11787379b87de608bf9c0f0934642371d82bb11049c7bb60ca9e5 |
| places-page-last.json | 1841b65ddf50d5d7df1539dab6c00d420ca08d21e037e989abc52c7c3f00458b |
| places-search.json | b4b940c583c90d689bdb6d53e50f6a66659021e0b5350b79a881ab9a6ebe3315 |
| roadevents-dewa.json | 7c5ca3c1117d17602c5702aec50d43014221d28bd3d38db995759c15dcbe002e |
| roadevents-empty.json | ccd96cccefd745c1a653313292682c0372d8b6ccec56f500c27f93a6d9673a38 |
| roadevents-type.json | cd5673cafa44893e0161a4c1c35e0c21794492e52f4ff11a59b7db4250f7b5c9 |
| roadevents-yell.json | cd5673cafa44893e0161a4c1c35e0c21794492e52f4ff11a59b7db4250f7b5c9 |
| thingstodo-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| thingstodo-page-first.json | 84da2d8510aca676afc2d8fca68f82c358c3bf79c9687cf160304e8de1c14544 |
| thingstodo-page-last.json | 844a678ac81713b3128ed806fad66718223cf39bd9c83d4e1efa37064fa55c50 |
| thingstodo-search.json | df1700c73e585d46183566bcd56b9964bb7b0ca3def44c316af85428cac46731 |
| tours-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| tours-page-first.json | fcdc5d7a9ce2645424fa3493574e72e6339cd021b591e53593cb80fecc60725e |
| tours-page-last.json | c5e2ab0840633bc7195de8158b213196af7d672140bac8c8770de1819daa0443 |
| tours-search.json | d7907082f538d779a24ad9f68dc768669139861fce954ed1c61d456665b1318f |
| visitorcenters-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| visitorcenters-page-first.json | 74e3a748da6a6cef310f6f4264681303e5fef66b8372a3bdbf3acc7665f8c7d8 |
| visitorcenters-page-last.json | 5584ce01ec607b53c20dc90e5faa0e8037edff031c7e37499e37c46f15d0eb7e |
| visitorcenters-search.json | 1202e83cb3141b0e2fd4c0ba8b03b9cc1338b168f1eb0640ba0376140cb5c441 |
| webcams-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| webcams-page-first.json | 2d10a5360308523cdf982b1154ca717a90ac145e37f850735a7bba39cee91c90 |
| webcams-page-last.json | 630a3097d90d640fccf795eaaf5a41a25a6c3241c6c6d7c5868f1e03136ce1c4 |
| webcams-search.json | a721995468f50de86e66be08134e4313debd7312e8c631d9862d03e9b5b6b6fe |

## Contract notes

Verified against the [official specification](https://www.nps.gov/subjects/developer/customcf/swagger.json)
and [authentication guide](https://www.nps.gov/subjects/developer/guides.htm).

- The live parks body is an object with `data`, `limit`, `start`, and `total`. The latter three
  are strings. The specification's outer response array declaration does not match this body.
- The parameter descriptions specify comma-delimited park codes, state codes, and sort criteria,
  while their Swagger collectionFormat says multi. These recordings confirm comma-delimited code
  filters and sorting in actual requests. The two park-code pages return acad then yell, total 2;
  start 2 returns an empty page. The state-filtered text search returns numeric relevance scores.
- The current parks specification lists only parkCode, stateCode, limit, start, q, and sort.
  It documents defaults 50 and 0, but no numeric maximum. Relevance sorting must be used alone.
- Park contacts, standard hours, and exception hours are objects, as in the schema properties;
  some illustrative examples incorrectly depict arrays. Costs are strings.
- The live `fees` field is absent from the current parks schema. It remains in the recordings
  but is not exposed by the typed model. Other unknown JSON fields are also ignored when decoding.
- The live alerts body uses the same string-valued `data`, `limit`, `start`, and `total` envelope;
  the specification again declares an outer array. Alerts accept parkCode, stateCode, q, limit,
  and start, with no sort parameter. The acad pages report total 4, so the two recorded pages are
  the first two of four. Every recorded alert has an empty `relatedRoadEvents` array; the element
  shape comes from the specification, and its decoding is covered by constructed test source.
  One recorded alert has an empty `url` string, preserved as sent.
- The live visitor centers body uses the same envelope. Visitor centers accept parkCode,
  stateCode, q, limit, start, and sort; sorting by `name` works, although NPS lists no sortable
  fields. The acad pages report total 6, so the two recorded pages are the first two of six.
- The specification declares visitor center `contacts` as an array of strings, but every recorded
  body sends an object with `emailAddresses` and `phoneNumbers`, identical to park contacts. The
  model follows the live object; no response in the specification's shape has been observed.
- The specification declares `isPassportStampLocation` a boolean, but the live value is the string
  `"0"` or `"1"`, kept as sent. Images carry a `crops` array, empty in these recordings except for
  one passport stamp image with a numeric `aspectRatio`. Every recorded `multimedia` array is empty,
  and `lastIndexedDate` is an empty string.
- The live campgrounds body uses the same envelope. Campgrounds accept parkCode, stateCode, q,
  limit, start, and sort; sorting by `name` works, although NPS lists no sortable fields. The acad
  pages report total 4, so the two recorded pages are the first two of four. The WY lake search
  reports total 26, and its first result has a Montana address, as sent.
- The live campground body differs from the specification's campground schema, and the model
  follows the live body. The specification spells the accessibility, amenities, and campsites keys
  and `directionsoverview`, `regulationsoverview`, and `weatheroverview` in lowercase; the live body
  sends camelCase, such as `wheelchairAccess`, `totalSites`, and `directionsOverview`. The
  specification spells `ampitheater`; the live key is `amphitheater`. The specification declares
  `fees`, `images`, and `operatingHours` as arrays of strings; the live body sends fee objects with
  `cost`, `description`, and `title`, image objects with `crops`, and operating hours objects
  identical to park hours.
- The specification names the reservation fields `reservationsdescription`,
  `reservationssitesfirstcome`, `reservationssitesreservable`, and `reservationsurl`; the live body
  sends `reservationInfo`, `numberOfSitesFirstComeFirstServe`, `numberOfSitesReservable`, and
  `reservationUrl`. The live body also sends `audioDescription`, `isPassportStampLocation` (the
  string `"0"` or `"1"`), `passportStampImages`, and `passportStampLocationDescription`, which the
  specification omits. The raw key `regulationsurl` is lowercase in both, and decodes as
  `regulationsUrl`.
- Every recorded campground `multimedia` array is empty, so the multimedia element shape rests on
  the specification's campground schema (`id`, `title`, `type`, `url`), the same as parks.
  Campground image crops are empty; passport stamp crops carry a numeric `aspectRatio`. Site counts,
  lengths, and flags are strings, including `"0"`, and `lastIndexedDate` is an empty string.
- The live places body uses the same envelope. `/places` accepts parkCode, stateCode, q, limit, and
  start. Every sort value tried against it answered HTTP 400 with an envelope carrying empty
  `total`, `start`, and `data`, so the query sends no sort parameter and the specification was not
  relied on for one. Recorded results arrive ordered by `title`, and `q` narrows the set without
  reordering it. The acad pages report total 181, so the two recorded pages are the first two of
  181. The FL Redoubt search reports total 27, with scores 16.06786 and 10.787928.
- The live places body sends both image crop forms in one response: `images` crops carry
  `aspectRatio` as the string `"1.78"`, while `passportStampImages` crops carry it as the number
  `1.0`. The four flags `isManagedByNps`, `isMapPinHidden`, `isOpenToPublic`, and
  `isPassportStampLocation` are the strings `"0"` and `"1"`. The searched place publishes a
  passport stamp image while sending `"0"` for `isPassportStampLocation`, so the two are
  independent. Coordinates arrive as three separate strings, `latitude`, `longitude`, and
  `latLong`, empty on the acad pages and populated in the search. `bodyText` and
  `audioDescription` carry HTML. Every recorded `relatedOrganizations` and `multimedia` array is
  empty, so those element shapes rest on the groups that populate them rather than on these
  recordings.
- The live things to do body uses the same envelope. Things to do accept id, parkCode, stateCode,
  q, limit, start, and sort. The specification documents `relevanceScore` as the only sort option,
  with descending date last modified as the default, and says an invalid sort property is
  ignored; the live service instead answers `sort=title` and `sort=-title` with HTTP 400 and an
  envelope with empty `total`, `start`, and `data`. The recordings therefore sort by
  `-relevanceScore`. The acad pages have no search text, report total 89, and every item scores
  1.0, so the two recorded pages are the first two of 89 in the provider's tie order. The ME hike
  search reports total 75 with scores 13.626645 and 12.141288.
- The live things to do body differs from the specification's schema, and the model follows the
  live body. The specification spells `arePetsPermittedwithRestrictions`; the live key is
  `arePetsPermittedWithRestrictions`. The specification spells the crop key `aspectratio` and types
  it as an integer; the live key is `aspectRatio` and its value is a string such as `"1.78"` or
  `"1"`. The visitor center and campground notes above record the other half of this divergence:
  those paths send a JSON number. Live images also carry a `description`, and the live body sends
  `credit` and `amenities`, none of which the specification lists. Flags such as
  `isReservationRequired` are the strings `"true"` and `"false"`, and coordinates, `age`,
  `duration`, and `geometryPoiId` are often empty strings.
- Every recorded things to do `relatedOrganizations` and `amenities` array is empty. The
  specification types related organizations as untyped objects and omits amenities, so their
  element shape is unknown; the typed model does not decode either field, and they are ignored like
  other unknown fields.
- `/mapdata/parkboundaries/{sitecode}` sends no NPS envelope. It returns a bare GeoJSON
  `FeatureCollection` with one feature, takes the park code as a path segment and no query
  parameters, and has no pagination. The code matched case-insensitively: `YELL` returned the same
  bytes as `yell`. An unknown code such as `zzzz` returns HTTP 404 with an
  `application/problem+json` body of `type`, `title`, `status`, and `traceId`, not the NPS error
  envelope, so the client reports it as a transport HTTP status failure.
- Park boundary geometry is usually a `MultiPolygon` nested four deep: most parks sampled, from 2
  polygons for drto to 51 for acad. Yellowstone and Glacier returned a `Polygon` nested three
  deep; the yell ring holds 1,494 positions and is closed. Every recorded position is two numbers,
  `[longitude, latitude]`, each written with a decimal point.
- Each boundary feature carries an `id`, which no specification lists; in the recordings it equals
  the park's identifier, also sent as each alias's `parkId`. Feature `properties` hold `aliases`
  (`{parkId, current, name, id}`, `current` a JSON Boolean and `name` the uppercase park code),
  `alternateName`, `designation` (`{abbreviation, parkDesignationCategoryId, name, description,
  id}`), `designationId`, `fullName`, and `name`. There is no park code, state list, or URL.
- `/roadevents` sends no NPS envelope. It returns a WZDx 4.1 GeoJSON `FeatureCollection` with
  `road_event_feed_info`, `features`, and `type`, snake_case keys throughout, and no pagination.
  The specification lists `parkCode` and `type`; both are optional, and a request with neither
  returns every park's events. `type` accepts `WorkZone`, `Detour`, `Restriction`, and `Incident`
  case-insensitively and answers `work-zone`, the WZDx spelling, and other values with HTTP 400.
  A valid type with no matches, such as `Detour` for yell, returns an empty feed with HTTP 200.
- `parkCode` takes one code. An unrecognized code, including a comma-separated list such as
  `yell,mora`, is ignored and the response is the full feed of every park, 607,279 bytes and 68
  features from 13 data sources when measured, while a recognized code with no events, such as
  acad, returns an empty feed. The dewa recording is one park's feed of 8 features.
- Every recorded geometry is a `LineString` of two-number `[longitude, latitude]` positions. Each
  feature's `properties` carry both `Id`, a UUID string, and `_id`, a number. `_id` counts from 0
  within a response: a dewa feature carries 0 in its park's feed and 51 in the full feed, so it is
  not a stable identifier. `end_date` is absent from some features. Incidents carry
  `types_of_incident`, an array of `{description, incident_category, incident_type}` the
  specification does not describe; one of 37 incidents in the full feed omits it. Work zones carry
  `types_of_work`, an array of `{type_name}`. `road_names` is an array of strings.
- The feed and data source contacts are organizational mailboxes such as `asknps@nps.gov` and
  `dewa_Superintendent@nps.gov`, kept as sent. The feed `update_date` predates its events. The data
  is licensed under the Creative Commons URL in `license`.
- The live tours body uses the same envelope. `/tours` accepts id, parkCode, stateCode, q, limit,
  start, and sort; `relevanceScore` is the only sort field the live service accepts, and the
  search recording sends `-relevanceScore` alongside every filter. The cavo pages report total 4,
  so the two recorded pages are the first two of four. The search reports total 1 with a score of
  19.48063.
- A tour links one park through a singular `park` object rather than a `relatedParks` array. Every
  stop `ordinal` is a string such as `"1"`, and `durationMin` and `durationMax` are strings with a
  separate `durationUnit`. Image crops carry `aspectRatio` as the numbers `1.78` and `1.0`, and no
  image has a `description`. Empty `significance`, `directionsToNextStop`, `audioTranscript`, and
  `audioFileUrl` strings and the search's empty `tags`, `activities`, and `topics` arrays are sent
  as recorded. Every recorded stop `assetType` is `"places"`; a scan of 500 live tours also found
  `"visitorcenters"` and `"campgrounds"`, and `durationUnit` values `"m"`, `"h"`, and `"d"`, so both
  stay open strings.
- The live webcams body uses the same envelope. `/webcams` accepts id, parkCode, stateCode, q,
  limit, and start; every `sort` value tried answers HTTP 400, so the query sends none. The grte
  pages report total 3, so the two recorded pages are the first two of three, and the search
  reports total 1.
- `isStreaming` is a JSON boolean: `true` on the first grte page and `false` on the second and in
  the search. `latitude` and `longitude` are JSON numbers, such as `31.923355102539062`, or JSON
  `null`, as both grte cameras send. Several cameras in one park can share a coordinate, so a
  coordinate is not a per-camera location. `status` is `"Active"` or `"Inactive"` in these
  recordings and stays an open string. The search image carries `crops: []`, an empty
  `description`, and a `url` beginning `https://www.nps.govhttps://www.nps.gov/`, all as sent.
- The live amenities body uses the same envelope. `/amenities` accepts id, q, limit, and start,
  with no park, state, or sort parameter. The specification lists `id` and `name` for an amenity;
  the live body also sends a `categories` array of strings, such as `["Convenience", "Souvenirs
  and Supplies"]`. The unfiltered pages report total 127 and the restroom search total 30.
- The live `/amenities/parksplaces` and `/amenities/parksvisitorcenters` bodies use the same
  envelope keys, but `data` is an array of arrays: each element is a group of amenity entries.
  Every recorded group holds exactly one entry, and diagnostic requests at `limit=3` returned
  three groups, so the service counts groups against `limit` and the recorded start advances by
  group count. Whether a group can hold more than one entry is not established. Each entry carries
  `id`, `name`, and `parks`; each park carries `states`, `designation`, `parkCode`, `fullName`,
  `url`, and `name`, plus `places` (`title`, `id`, `url`) or lowercase `visitorcenters` (`id`,
  `url`, `name`). The acad pages report totals 59 and 27, and their `start=1` pages are the second
  group, not the collection's last. Park and visitor center links mix `http` and `https` as sent.
- The guide supports `X-Api-Key` as well as the query key represented in the Swagger security
  definition. The SDK uses the header exclusively and refuses redirects.
- The guide documents HTTP 429 for rate limiting, and limits can vary. The public demonstration
  credential reported a limit of 10 and the private key a limit of 1,000 for these recordings. No
  rate-limit response was forced.
- Constructed edge cases in test source cover malformed data, unknown values, and status
  failures; they are explicitly separate from these recordings.
- A personal email address in the recorded `visitorcenters-search.json` body was replaced with
  `redacted@example.com`; the listed sha256 is of the original recording.

NPS content and media retain their [upstream usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
No referenced image or media file is downloaded into these fixtures.
