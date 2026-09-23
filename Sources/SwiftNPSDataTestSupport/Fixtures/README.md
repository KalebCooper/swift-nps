# Recorded responses

Recorded from the NPS Data API on September 13, 2026 (parks and the missing key) and September 17,
2026 (alerts, amenities, campgrounds, things to do, and visitor centers), and September 20, 2026
(park boundaries, places, road events, tours, and webcams), and September 21, 2026 (articles, news
releases, park audio, park videos, people, photo galleries, photo gallery assets, and parking
lots), and September 22, 2026 (activities, activity parks, lesson plans, park fees and passes,
passport stamp locations, topic parks, and topics) using the application identity
`(swift-nps, https://github.com/KalebCooper/swift-nps)`.
These are real response bodies, not examples copied from the specification. Tests read them
locally and never contact NPS.

| File | Exact request | HTTP status |
| --- | --- | --- |
| activities-empty.json | GET https://developer.nps.gov/api/v1/activities?limit=1&parkCode=zzzz&start=0 | 200 |
| activities-page-first.json | GET https://developer.nps.gov/api/v1/activities?id=AE42B46C-E4B7-4889-A122-08FE180371AE,0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=0 | 200 |
| activities-page-last.json | GET https://developer.nps.gov/api/v1/activities?id=AE42B46C-E4B7-4889-A122-08FE180371AE,0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=1 | 200 |
| activities-search.json | GET https://developer.nps.gov/api/v1/activities?limit=2&parkCode=cwdw,drto&q=tours&sort=-name&start=0 | 200 |
| activities-parks-empty.json | GET https://developer.nps.gov/api/v1/activities/parks?limit=1&parkCode=zzzz&start=0 | 200 |
| activities-parks-page-first.json | GET https://developer.nps.gov/api/v1/activities/parks?id=AE42B46C-E4B7-4889-A122-08FE180371AE,0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=0 | 200 |
| activities-parks-page-last.json | GET https://developer.nps.gov/api/v1/activities/parks?id=AE42B46C-E4B7-4889-A122-08FE180371AE,0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=1 | 200 |
| activities-parks-search.json | GET https://developer.nps.gov/api/v1/activities/parks?id=B33DC9B6-0B7D-4322-BAD7-A13A34C584A3,0B685688-3405-4E2A-ABBA-E3069492EC50&limit=2&parkCode=cwdw,drto&q=tours&sort=-name&start=0 | 200 |
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
| articles-empty.json | GET https://developer.nps.gov/api/v1/articles?limit=1&parkCode=zzzz&start=0 | 200 |
| articles-page-first.json | GET https://developer.nps.gov/api/v1/articles?limit=1&parkCode=arch&start=0 | 200 |
| articles-page-last.json | GET https://developer.nps.gov/api/v1/articles?limit=1&parkCode=arch&start=1 | 200 |
| articles-search.json | GET https://developer.nps.gov/api/v1/articles?limit=2&parkCode=gumo&q=Salt&start=0&stateCode=TX | 200 |
| assets-empty.json | GET https://developer.nps.gov/api/v1/multimedia/galleries/assets?limit=1&parkCode=zzzz&start=0 | 200 |
| assets-gallery.json | GET https://developer.nps.gov/api/v1/multimedia/galleries/assets?galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20&limit=2&start=0 | 200 |
| assets-page-first.json | GET https://developer.nps.gov/api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=0 | 200 |
| assets-page-last.json | GET https://developer.nps.gov/api/v1/multimedia/galleries/assets?limit=1&parkCode=cowp&start=1 | 200 |
| assets-search.json | GET https://developer.nps.gov/api/v1/multimedia/galleries/assets?limit=2&parkCode=heho&q=snow&sort=title&start=0&stateCode=IA | 200 |
| audio-empty.json | GET https://developer.nps.gov/api/v1/multimedia/audio?limit=1&parkCode=zzzz&start=0 | 200 |
| audio-page-first.json | GET https://developer.nps.gov/api/v1/multimedia/audio?limit=1&parkCode=choh&start=0 | 200 |
| audio-page-last.json | GET https://developer.nps.gov/api/v1/multimedia/audio?limit=1&parkCode=choh&start=1 | 200 |
| audio-search.json | GET https://developer.nps.gov/api/v1/multimedia/audio?limit=2&parkCode=ever&q=alligator&sort=title&start=0&stateCode=FL | 200 |
| campgrounds-empty.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=1&parkCode=zzzz&start=0 | 200 |
| campgrounds-page-first.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=0 | 200 |
| campgrounds-page-last.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=1 | 200 |
| campgrounds-search.json | GET https://developer.nps.gov/api/v1/campgrounds?limit=2&q=lake&sort=name&start=0&stateCode=WY | 200 |
| lessonplans-empty.json | GET https://developer.nps.gov/api/v1/lessonplans?limit=1&parkCode=zzzz&start=0 | 200 |
| lessonplans-page-first.json | GET https://developer.nps.gov/api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=0 | 200 |
| lessonplans-page-last.json | GET https://developer.nps.gov/api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=1 | 200 |
| lessonplans-search.json | GET https://developer.nps.gov/api/v1/lessonplans?limit=2&parkCode=grte,yell&q=bear&start=0&stateCode=WY | 200 |
| feespasses-empty.json | GET https://developer.nps.gov/api/v1/feespasses?limit=1&parkCode=zzzz&start=0 | 200 |
| feespasses-page-first.json | GET https://developer.nps.gov/api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=0 | 200 |
| feespasses-page-last.json | GET https://developer.nps.gov/api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=1 | 200 |
| feespasses-search.json | GET https://developer.nps.gov/api/v1/feespasses?limit=2&parkCode=deva,fova&q=annual&start=0&stateCode=CA,WA | 200 |
| galleries-empty.json | GET https://developer.nps.gov/api/v1/multimedia/galleries?limit=1&parkCode=zzzz&start=0 | 200 |
| galleries-page-first.json | GET https://developer.nps.gov/api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=0 | 200 |
| galleries-page-last.json | GET https://developer.nps.gov/api/v1/multimedia/galleries?limit=1&parkCode=thrb&start=1 | 200 |
| galleries-search.json | GET https://developer.nps.gov/api/v1/multimedia/galleries?limit=2&parkCode=heho&q=snow&sort=title&start=0&stateCode=IA | 200 |
| newsreleases-empty.json | GET https://developer.nps.gov/api/v1/newsreleases?limit=1&parkCode=zzzz&start=0 | 200 |
| newsreleases-page-first.json | GET https://developer.nps.gov/api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=0 | 200 |
| newsreleases-page-last.json | GET https://developer.nps.gov/api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=1 | 200 |
| newsreleases-search.json | GET https://developer.nps.gov/api/v1/newsreleases?limit=2&parkCode=anac&q=advisory&sort=title&start=0&stateCode=DC | 200 |
| parkboundaries-drto.json | GET https://developer.nps.gov/api/v1/mapdata/parkboundaries/drto | 200 |
| parkboundaries-unknown.json | GET https://developer.nps.gov/api/v1/mapdata/parkboundaries/zzzz | 404 |
| parkboundaries-yell.json | GET https://developer.nps.gov/api/v1/mapdata/parkboundaries/yell | 200 |
| parkinglots-empty.json | GET https://developer.nps.gov/api/v1/parkinglots?limit=1&parkCode=zzzz&start=0 | 200 |
| parkinglots-page-first.json | GET https://developer.nps.gov/api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=0 | 200 |
| parkinglots-page-last.json | GET https://developer.nps.gov/api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=1 | 200 |
| parkinglots-search.json | GET https://developer.nps.gov/api/v1/parkinglots?limit=2&parkCode=havo&q=overlook&sort=name&start=0&stateCode=HI | 200 |
| parks-acad.json | GET https://developer.nps.gov/api/v1/parks?parkCode=acad&limit=1&start=0 | 200 |
| parks-beyond.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=2 | 200 |
| parks-empty.json | GET https://developer.nps.gov/api/v1/parks?parkCode=zzzz&limit=1&start=0 | 200 |
| parks-page-first.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0 | 200 |
| parks-page-last.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=1 | 200 |
| parks-search.json | GET https://developer.nps.gov/api/v1/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA | 200 |
| parks-yell.json | GET https://developer.nps.gov/api/v1/parks?parkCode=yell&limit=1&start=0 | 200 |
| passportstamplocations-empty.json | GET https://developer.nps.gov/api/v1/passportstamplocations?limit=1&parkCode=zzzz&start=0 | 200 |
| passportstamplocations-page-first.json | GET https://developer.nps.gov/api/v1/passportstamplocations?id=74C8535F-4F9C-411F-B3F1-AE14E8C14AA2,9EE76DDC-80AB-4283-BCE9-F85952ED03E1&limit=1&parkCode=cato&sort=-name&start=0 | 200 |
| passportstamplocations-page-last.json | GET https://developer.nps.gov/api/v1/passportstamplocations?id=74C8535F-4F9C-411F-B3F1-AE14E8C14AA2,9EE76DDC-80AB-4283-BCE9-F85952ED03E1&limit=1&parkCode=cato&sort=-name&start=1 | 200 |
| passportstamplocations-search.json | GET https://developer.nps.gov/api/v1/passportstamplocations?limit=3&parkCode=cagr,mamc&q=national&sort=-name&start=0&stateCode=AZ,DC | 200 |
| people-empty.json | GET https://developer.nps.gov/api/v1/people?limit=1&parkCode=zzzz&start=0 | 200 |
| people-page-first.json | GET https://developer.nps.gov/api/v1/people?limit=1&parkCode=yell&start=0 | 200 |
| people-page-last.json | GET https://developer.nps.gov/api/v1/people?limit=1&parkCode=yell&start=1 | 200 |
| people-search.json | GET https://developer.nps.gov/api/v1/people?limit=2&parkCode=frla&q=Olmsted&start=0&stateCode=MA | 200 |
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
| topics-parks-empty.json | GET https://developer.nps.gov/api/v1/topics/parks?limit=1&parkCode=zzzz&start=0 | 200 |
| topics-parks-page-first.json | GET https://developer.nps.gov/api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=0 | 200 |
| topics-parks-page-last.json | GET https://developer.nps.gov/api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=1 | 200 |
| topics-parks-search.json | GET https://developer.nps.gov/api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=2&parkCode=acad,mamc&q=history&sort=-name&start=0 | 200 |
| topics-empty.json | GET https://developer.nps.gov/api/v1/topics?limit=1&parkCode=zzzz&start=0 | 200 |
| topics-page-first.json | GET https://developer.nps.gov/api/v1/topics?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=0 | 200 |
| topics-page-last.json | GET https://developer.nps.gov/api/v1/topics?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=1 | 200 |
| topics-search.json | GET https://developer.nps.gov/api/v1/topics?limit=2&parkCode=acad,mamc&q=history&sort=-name&start=0 | 200 |
| tours-empty.json | GET https://developer.nps.gov/api/v1/tours?limit=1&parkCode=zzzz&start=0 | 200 |
| tours-page-first.json | GET https://developer.nps.gov/api/v1/tours?limit=1&parkCode=cavo&start=0 | 200 |
| tours-page-last.json | GET https://developer.nps.gov/api/v1/tours?limit=1&parkCode=cavo&start=1 | 200 |
| tours-search.json | GET https://developer.nps.gov/api/v1/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1&limit=2&parkCode=foma&q=Virtual&sort=-relevanceScore&start=0&stateCode=FL | 200 |
| videos-empty.json | GET https://developer.nps.gov/api/v1/multimedia/videos?limit=1&parkCode=zzzz&start=0 | 200 |
| videos-page-first.json | GET https://developer.nps.gov/api/v1/multimedia/videos?limit=1&parkCode=crmo&start=0 | 200 |
| videos-page-last.json | GET https://developer.nps.gov/api/v1/multimedia/videos?limit=1&parkCode=crmo&start=1 | 200 |
| videos-search.json | GET https://developer.nps.gov/api/v1/multimedia/videos?limit=2&parkCode=boaf&q=Boston&sort=title&start=0&stateCode=MA | 200 |
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
limit of 10. The campgrounds, things to do, and amenities recordings, the park boundaries, places,
road events, tours, and webcams recordings made on September 20, and every recording made on
September 21, used the maintainer's private key, which reported a limit of 1,000. No request headers
or credentials are stored. The missing-key recording deliberately omitted that header. Response
ordering is retained, rather than alphabetized, to preserve the provider's representation.

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
and are left as sent; the one em dash in each of the two acad pages already arrives as the escape
`\u2014`.
The empty recording is byte-identical to the other empty recordings. Decoded values were compared
with the downloads and are identical.

The tours recordings arrived with CRLF line endings, blank lines, and commas leading each line, and
are reindented the same way, keeping the provider's key order and the numeric aspect ratios `1.78`
and `1.00` as written. They are ASCII throughout and contain no escapes. The empty recording is
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

The articles recordings arrived with CRLF line endings, blank lines, trailing spaces, and commas
leading each line, and are reindented the same way, keeping the provider's key order and the
coordinates and `null` values as written. They are ASCII throughout; the em dash in the second
arch title already arrives as the escape `\u2014`. The empty recording is byte-identical to the
other empty recordings. Decoded values were compared with the downloads and are identical.

The news releases recordings arrived with CRLF line endings, blank lines, trailing spaces, and
commas leading each line, and are reindented the same way, keeping the provider's key order, the
timestamps, and the `null` values as written. The search recording keeps two raw UTF-8 en dashes
in its abstracts; the pages are ASCII throughout. The empty recording is byte-identical to the
other empty recordings. No recording carries personal contact details, so nothing was redacted.
Decoded values were compared with the downloads and are identical.

The people recordings arrived with CRLF line endings and are reindented the same way, keeping the
provider's key order, the HTML in `bodyText`, and the coordinate text as written. They keep raw
UTF-8 no-break spaces, curly quotes and apostrophes, and en dashes in their HTML and summaries,
with no JSON Unicode escapes. The empty recording is byte-identical to the other empty
recordings. The recordings profile historical figures (Thomas Moran, Horace M. Albright, and John
and Marion Olmsted) and carry no personal contact details, so nothing was redacted. Decoded values
were compared with the downloads and are identical.

The park audio recordings arrived with CRLF line endings, blank lines, trailing spaces, and commas
leading each line, and are reindented the same way, keeping the provider's key order, the
transcripts, and the numbers and `null` values as written. The recordings are ASCII throughout.
The search recording's results are NPS Natural Sounds Program recordings with empty transcripts.
The empty recording is byte-identical to the other empty recordings. Credits are empty or name
an NPS program, no recording names a member of the public, and no recording carries personal
contact details, so nothing was redacted. Decoded values were compared with the downloads and are
identical.

The park video recordings arrived with the same CRLF layout as the park audio recordings and are
reindented the same way, keeping the provider's key order and the numbers, Booleans, and `null`
values as written. The pages are ASCII throughout. The search recording keeps one raw UTF-8
`é` in `Kouyaté` and has no JSON Unicode escapes. The empty recording is byte-identical
to the other empty recordings. Credits and the second search description name producers,
artists, and public speakers, and no recording carries personal contact details, so nothing was
redacted. Decoded values were compared with the downloads and are identical.

The photo gallery recordings arrived with the same CRLF layout as the park audio recordings and
are reindented the same way, keeping the provider's key order and the numbers as written. The
pages are ASCII throughout and have no JSON Unicode escapes. The empty recording is
byte-identical to the other empty recordings. Image descriptions name photographers, such as
`NPS/Denise Collar`, and no recording carries personal contact details, so nothing was redacted.
Decoded values were compared with the downloads and are identical.

The photo gallery asset recordings arrived with the same CRLF layout and are reindented the same
way, keeping the provider's key order and the numbers as written. The pages are ASCII throughout
and have no JSON Unicode escapes. The empty recording is byte-identical to the other empty
recordings. Credits name institutions and archives, such as `NPS photo` and `National Archives &
Records Administration`, and no recording carries personal contact details, so nothing was
redacted. Decoded values were compared with the downloads and are identical.

The parking lot recordings arrived with CRLF line endings, blank lines, trailing spaces, and
commas leading each line, and are reindented the same way, keeping the provider's key order and
the numbers, Booleans, and `null` values as written. The search recording keeps raw UTF-8
Hawaiian diacritics in park and lot names, with no JSON Unicode escapes; the other three pages
are ASCII throughout. The empty recording is byte-identical to the other empty recordings.
Contacts are park phone and fax lines and `*_info@nps.gov`-style inboxes, and image credits name
NPS photographers, so nothing was redacted. Decoded values were compared with the downloads and
are identical.

The activities recordings arrived with the same CRLF layout and are reindented the same way,
keeping the provider's key order. They are ASCII only, with no JSON escapes. The empty recording
is byte-identical to the other empty recordings. Swagger documents no sort or park-code parameter
for `/activities`, but the live endpoint accepts `sort=name`/`-name` (HTTP 400 on other fields) and
`parkCode` narrows the returned activities, so `ActivityQuery` sends both. The recordings name only
activities, with no people or contact details, so nothing was redacted. Decoded values were
compared with the downloads and are identical.

The activity parks recordings arrived with the same CRLF layout and are reindented the same way,
keeping the provider's key order. They are ASCII only, with no JSON escapes. The empty recording
is byte-identical to the other empty recordings. The recordings name only activities and parks,
with no people or contact details, so nothing was redacted. Decoded values were compared with the
downloads and are identical.

The park fees and passes recordings arrived with the same CRLF layout and are reindented the same
way, keeping the provider's key order and the integers, Booleans, and `null` values as written.
The two Hawaii pages keep raw UTF-8 Hawaiian diacritics, and the first also an em dash, while
the search page keeps a raw UTF-8 right single quotation mark in a holiday name, with no JSON
Unicode escapes. The empty
recording is byte-identical to the other empty recordings. The only image credit is an
institutional NPS credit, one image shows unnamed visitors on a ranger-led tour, and no recording
carries names of private individuals or personal contact details, so nothing was redacted.
Decoded values were compared with the downloads and are identical.

The lesson plans recordings arrived with the same CRLF layout and are reindented the same way,
keeping the provider's key order. They carry no JSON escapes; their non-ASCII characters, such as
bullets and a typographic apostrophe in one `questionObjective`, arrive as raw UTF-8 and are kept.
The empty recording is byte-identical to the other empty recordings. The recordings name lessons,
parks, grade ranges, and education standards, with no teacher, student, or other individual named
and no contact details, so nothing was redacted. Decoded values were compared with the downloads
and are identical.

The topic parks recordings arrived with the same CRLF layout and are reindented the same way,
keeping the provider's key order. They are ASCII only; the one JSON escape is the carriage return
and line feed ending one park's `designation`, kept as written. The empty recording is
byte-identical to the other empty recordings. The recordings name only topics and parks, with no
people or contact details, so nothing was redacted. Decoded values were compared with the
downloads and are identical.

The topics recordings arrived with the same CRLF layout and are reindented the same way, keeping
the provider's key order. They are ASCII only, with no JSON escapes. The empty recording is
byte-identical to the other empty recordings. Swagger documents no sort or park-code parameter for
`/topics`, but the live endpoint accepts `sort=name`/`-name` (HTTP 400 on other fields) and
`parkCode` narrows the returned topics, so `TopicQuery` sends both. The recordings name only
topics, with no people or contact details, so nothing was redacted. Decoded values were compared
with the downloads and are identical.

The passport stamp locations recordings arrived with the same CRLF layout and are reindented the
same way, keeping the provider's key order. They are ASCII only; the search recording keeps the
one JSON escape the provider sent, the `\r\n` ending one park's `designation`. The empty recording
is byte-identical to the other empty recordings. The recordings name only locations and parks,
with no people or contact details, so nothing was redacted. Decoded values were compared with the
downloads and are identical.

The parks pagination and search recordings additionally escape non-ASCII characters using JSON
Unicode escapes. Their decoded values were compared with the downloads and are identical.

SHA-256 of the original downloaded bodies, before whitespace normalization and lossless escaping:

| File | SHA-256 |
| --- | --- |
| activities-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| activities-page-first.json | eeb34a9ae73a5a015ce60e517240f6767b6a92df75afba8959034f0daedaa53c |
| activities-page-last.json | 308085d723d8005fe19f19aeaa426e27029bd1f3a07cfe42c30cb5a4c0a7c540 |
| activities-search.json | 27b2f3e6453b7c5e42408ca002f2dc3c1a9a6e8e49de116706d32e817a265416 |
| activities-parks-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| activities-parks-page-first.json | b97f15c7ba10e69cbee4925257b804db8e0e610db21fed34f793e9942dbbd46a |
| activities-parks-page-last.json | f6cbe6960f5bfb01b22f112c5c6bed36a5331e32605959b3d11d94679c067d8f |
| activities-parks-search.json | d525157167373a331a589641db744d7de842f0044322c5d6661143d4e72e91ea |
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
| articles-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| articles-page-first.json | f00b3950dd2d0a77cb2e6123a896204a210d64f120abd9214f8c4b99505066be |
| articles-page-last.json | 5a30c5473bd9e41adbd330741a4f913ec2a35f8bba487cca502b17801c5d5d5b |
| articles-search.json | e065b61a3da949bca37cdbe79a5c03f91fff6b1eadd499661f66bc718f6e23d6 |
| assets-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| assets-gallery.json | 54c6fb070260d79b4cb59e138624a028a990a8e1281e806e64814315e4777f17 |
| assets-page-first.json | 57252f9678555679988c849b75c1d85217e65070a6c0450f734c7f9fe0c8ebf1 |
| assets-page-last.json | abfb6a956d0f8cce303c892fc5d4f802515985a7dd723e72105d3b81af13f865 |
| assets-search.json | 02133baef9d6d22a7b859fa9a8489c669c23bde21eafccd742c173e17981603a |
| audio-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| audio-page-first.json | 59871cdb65a7115979ef5dabc830a1b27d89b0241ac99c6952db2f6da079de7d |
| audio-page-last.json | a3e682956644b22ce219eb812ff3eb0d78a887f5f3705a01ae310c06c42eb004 |
| audio-search.json | e3c05a5768b2183f745bff2955986cbe0736c93b47cb0a178c021a35a58d9241 |
| campgrounds-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| campgrounds-page-first.json | 452d7fa85a1cd58f954961e3716b8c2075ad8bc9d4b13e1acaa58bb452251742 |
| campgrounds-page-last.json | 4778b70345af7bd999e4943e99dc43dfe227e9eba2fcef57b8dcebf3418aa104 |
| campgrounds-search.json | e1f09e544bd067518b0a5b8561c5f360d884818dcb0c0f12d7c1e291fa926f77 |
| lessonplans-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| lessonplans-page-first.json | 69e133637426a388948f691303e109ca2fea08d59ffbe3354c54b581f61f058b |
| lessonplans-page-last.json | 4b6d4c711ac5238dbba50b936544fd7ce678e43d43ffbb3022837d74b74f533a |
| lessonplans-search.json | c6e9740ccbc9cec94a887d0a07392287efd9efd79892153269bfac5ae60a97db |
| feespasses-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| feespasses-page-first.json | 42dbd82cc0e138f2451b4e7b58273041d9954b167de800d029786104fce06a2e |
| feespasses-page-last.json | 682cc43649a647419ce887093a3b6e99e96fdfa28d4f5078ce91ef3f0a26e549 |
| feespasses-search.json | f1dca8012938b3d0f143bea1e9af0e7c13c6a06f39be5cb3bb6d803992e36429 |
| galleries-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| galleries-page-first.json | b50027cd0f1718a2657cf8ff491375f7ef07cbf2e24750c34c32fc5dfe347489 |
| galleries-page-last.json | f7958e2b1ff2d14df4a2fd62abd1d85dde303a11dd3a0dedd2164e5ba45c03ca |
| galleries-search.json | 54b6742086d6f627029001e1a694d7ea8e8d61c06293e1dda44a0e0ee379815c |
| newsreleases-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| newsreleases-page-first.json | e00fd9ea4dd876e9ce981ec239ec3f30df3e19c918a97c452c084170abf8a195 |
| newsreleases-page-last.json | 8a45756aa96edb222915ce422d54496b1f1c3d9d5dd3abcb28cb7fcc341a8217 |
| newsreleases-search.json | fa6e197527f2b791cba336de47f7db4bcbdc942112bfccc1656999c9aefb81e0 |
| parkboundaries-drto.json | 8c87bc141d6bdf4580cf166a902a2700ba810c8bd17327489e87d72a454c7885 |
| parkboundaries-unknown.json | c4e912cc04e9b3426cd17b27a5d01eba6442efc6fb3c5be30181679fb996330b |
| parkboundaries-yell.json | 96a49dd65006cfb7901a035ba26a6aa22d0bcfc70577f1aad25f36b1e03a70ed |
| parkinglots-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| parkinglots-page-first.json | 945b56560b973e5dfafa5de16fcae4a89a80d208e8b41a0e7d0c38af8ef606e7 |
| parkinglots-page-last.json | 6f5c72b498d46fc08df976b8f5756715cf9f1c316d608c0a50be655c43298cd0 |
| parkinglots-search.json | dd6d46befe6ecedd9ff5d7a915232a2cff015aa78136967afba931a9ee077dd2 |
| parks-acad.json | 190b90f17bff221b71e564247b265a581844143b4eeca8455674ad47154f4632 |
| parks-beyond.json | bc6e94934ea41746830b8df13e264efc9eef42d9fe23ace5e61d81c6d728996d |
| parks-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| parks-page-first.json | bdf759dc187c206a91cb7b90ac5f667c2329de3734a4ede7bd20b37f1e82239d |
| parks-page-last.json | 76e1eeea6fde0f15c64aab4f073f068002f1dde043b332aa197725798da0f8d2 |
| parks-search.json | 1302400226103d947077e3d10908462b433ffc6b1e69511807af852640a67009 |
| parks-yell.json | 243bbc33c1ffee6ff2d86794e2b546d32da28c9a9f605449aa2e88968697b53d |
| passportstamplocations-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| passportstamplocations-page-first.json | 9a5062f3d9784e78abeae41fc974376177af9f5cc93857c99593edd6ae74740d |
| passportstamplocations-page-last.json | bff520da1a093497a12901e08daf43e7f8a78ee0ccdcfce9aa38654f04f5ddc8 |
| passportstamplocations-search.json | acbe46c16f1a04b6a66f592cae1ee4bb7627739780015e3d32825bc64d6e2126 |
| people-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| people-page-first.json | 87f3fe2ee2f08e81a155cb984cfd36b01ddc632ef02877fe28fdc0018fac7908 |
| people-page-last.json | 5d72b28bf7d91b9c0a50345f67876f423aa4b4ee53e9d4ae5b6457df38ff0435 |
| people-search.json | b6cbf03fd73fb0d7cf458fa5df52697e2de865023cb035b8c6bfb68fd137f25b |
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
| topics-parks-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| topics-parks-page-first.json | 44afa2cb5adb74cb5fbca8c1a6c20ff04a26609f0e400befd0eace5a643b9676 |
| topics-parks-page-last.json | 2e26944856fd547d408bd333b794256035e253ee6a33075c20960f7f6148fa89 |
| topics-parks-search.json | d2135eb27989003ad307aed350fc572950db952bc0b22d742424dddfb5c49464 |
| topics-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| topics-page-first.json | 79da1d609bc3b663ed12317221103c6253f4dad68e556a9737bb22e559a3cdca |
| topics-page-last.json | 750aacca917616dad4ee5ba5a6461c0f59653598175ef5a9b63f60f96b023f07 |
| topics-search.json | 4c40b2b170b8115870d282e1bce2be6dbdfe1cdc1f7a9c93545cb00a14c52406 |
| tours-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| tours-page-first.json | fcdc5d7a9ce2645424fa3493574e72e6339cd021b591e53593cb80fecc60725e |
| tours-page-last.json | c5e2ab0840633bc7195de8158b213196af7d672140bac8c8770de1819daa0443 |
| tours-search.json | d7907082f538d779a24ad9f68dc768669139861fce954ed1c61d456665b1318f |
| videos-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| videos-page-first.json | 92da7aa6a34a339a2264918f2941956de2dcdf61545e653bae4046b7ce8e3950 |
| videos-page-last.json | e4918b4a92570e643b20a13c2692b8b2a639afbe5743e1ccb9bf52ad0dfa71c5 |
| videos-search.json | 48ebf9aaba5c6e6ecfdb0122f3244da77723712b456ae4d9d45a5863be700a0c |
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
  parameters, and has no pagination. The code matched case-insensitively: a live probe of `YELL`
  returned the same bytes as `yell`. An unknown code such as `zzzz` returns HTTP 404 with an
  `application/problem+json` body of `type`, `title`, `status`, and `traceId`, not the NPS error
  envelope, so the client reports it as a transport HTTP status failure.
- Park boundary geometry is usually a `MultiPolygon` nested four deep: most parks probed live, and
  the recorded drto boundary holds 2 polygons. Live probes returned 51 polygons for acad, and a
  `Polygon` nested three deep for yell and glac; the recorded yell ring holds 1,494 positions and
  is closed. Every recorded position is two numbers,
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
  A live probe of a valid type with no matches, `Detour` for yell, returned an empty feed with
  HTTP 200.
- `parkCode` takes one code. An unrecognized code, including a comma-separated list such as
  `yell,mora`, is ignored and the response is the full feed of every park; a live probe measured
  607,279 bytes and 68 features from 13 data sources. A recognized code with no events, such as
  acad, returns an empty feed. The dewa recording is one park's feed of 8 features, and no full
  feed is recorded here.
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
  separate `durationUnit`. Image crops carry `aspectRatio` as the numbers `1.78` and `1.00`, and no
  image has a `description`. Empty `significance`, `directionsToNextStop`, `audioTranscript`, and
  `audioFileUrl` strings and the search's empty `tags`, `activities`, and `topics` arrays are sent
  as recorded. Every recorded stop `assetType` is `"places"`; a live scan of 500 tours also found
  `"visitorcenters"` and `"campgrounds"`, and `durationUnit` values `"m"`, `"h"`, and `"d"`, neither
  of which any recording here holds, so both stay open strings.
- The live webcams body uses the same envelope. `/webcams` accepts id, parkCode, stateCode, q,
  limit, and start; every `sort` value tried answers HTTP 400, so the query sends none. The grte
  pages report total 3, so the two recorded pages are the first two of three, and the search
  reports total 1.
- `isStreaming` is a JSON boolean: `true` on the first grte page and `false` on the second and in
  the search. `latitude` and `longitude` are JSON numbers, such as `31.923355102539062`, or JSON
  `null`, as both grte cameras send; the gumo search camera is the only recorded camera with
  numbers. A live probe found several cameras in one park sharing a coordinate, so a coordinate is
  not a per-camera location. `status` is `"Active"` or `"Inactive"` in these
  recordings and stays an open string. The search image carries `crops: []`, an empty
  `description`, and a `url` beginning `https://www.nps.govhttps://www.nps.gov/`, all as sent.
- The live articles body uses the same envelope. `/articles` accepts parkCode, stateCode, q,
  limit, and start; `sort=title` answers HTTP 400 with an empty envelope, so the query sends no
  sort. The arch pages report total 117, so the two recorded pages are the first two, and the
  gumo search reports total 3. Every article sends `latitude` and `longitude` as JSON numbers,
  such as `31.976943969726562`, or JSON `null`, and `latLong` as text such as
  `"{lat:31.976943969726562, long:-104.75194549560547}"` or an empty string. A live scan of 500
  articles found 79 with coordinates. `listingImage` is one object with `url`, `credit`, `altText`,
  `title`, `description`, and `caption`, and no `crops` key in any recording or in that scan.
  `credit` and `geometryPoiId` are empty strings in these recordings.
- The live news releases body uses the same envelope. `/newsreleases` accepts parkCode,
  stateCode, q, sort, limit, and start. `sort=releaseDate`, `sort=-releaseDate`, and `sort=title`
  each answer HTTP 200 in the order named, while `sort=relevanceScore` answers HTTP 400 with an
  empty envelope. The yell pages report total 19, so the two recorded pages are the newest two, and
  the anac search reports total 2. `releaseDate` and `lastIndexedDate` are text such as
  `"2026-09-17 15:34:00.0"`, not ISO 8601 and with no time zone. The summary key is `abstract`.
  `parkCode` is text: one code, a comma-separated list such as `"anac,nace"`, or an empty string
  (20 lists and 11 empty strings in a live scan of 500 releases). `image` is one object with
  `url`, `credit`, `altText`, `title`, `description`, and `caption`, never `crops`, and the search
  images send every field empty. `relatedOrganizations` elements are `{id, url, name}`; the scan
  found 24 populated, and both search results carry `US Park Police`. `latitude` and `longitude`
  were JSON `null` in every scanned release, and no release sends `latLong` or `tags`.
- The live park audio body uses the same envelope. `/multimedia/audio` accepts parkCode,
  stateCode, q, sort, limit, and start. `sort=title` and `sort=-title` each answer HTTP 200 in the
  order named, while `sort=relevanceScore` and an unknown field answer HTTP 400 with an empty
  envelope. The choh pages report total 13 and the thro search reports total 5. In a live scan of
  500 recordings, every item carries one `versions` entry of `{fileSize, fileType, url}` with
  `fileType` `audio/mp3`; `fileSize` is a JSON number such as `170844.0`, 91 of the 500 send `0.0`,
  and NPS documents no unit for it. `transcript` is plain text or HTML (171 of 500 begin with a
  tag). `splashImage` carries only `url`, empty in 472 of 500. `latitude` and `longitude` are JSON
  numbers or `null` (112 of 500 send numbers), and `durationMs` is a JSON integer or `null` (8 of
  500, including the second search result). Every `permalinkUrl` points at
  `https://www.nps.gov/media/video/view.htm`, even for audio.
- The live park videos body uses the same envelope. `/multimedia/videos` accepts parkCode,
  stateCode, q, sort, limit, and start. `sort=title` and `sort=-title` each answer HTTP 200 in the
  order named, while `sort=relevanceScore` and an unknown field answer HTTP 400 with an empty
  envelope. The crmo pages report total 25 and the boaf search reports total 17. In a live scan of
  500 videos, `audioDescribedBuiltIn`, `hasOpenCaptions`, `isVideoOnly`, and `isBRoll` are real
  JSON Booleans (48, 36, 4, and 45 of 500 true). `versions` holds 1,777 renditions of
  `{fileSizeKb, fileType, aspectRatio, heightPixels, url, widthPixels}`, and one video sends an
  empty array; `fileType` is `video/mp4`, `aspectRatio` a JSON number such as `1.778`, and
  `fileSizeKb` a JSON number such as `15976.0` or `null` (746 of 1,777), for which NPS documents
  no unit. `captionFiles` elements are `{language, fileType, url}` with `fileType` `text/vtt` and
  `language` `english` or `spanish`; 335 of 500 videos carry at least one and the rest send an
  empty array. `latitude` and `longitude` are JSON numbers or `null`, and `durationMs` a JSON
  integer or `null`.
- The live photo galleries body uses the same envelope. `/multimedia/galleries` accepts
  parkCode, stateCode, q, sort, limit, and start. `sort=title` and `sort=-title` each answer HTTP
  200 in the order named, while `sort=relevanceScore` and an unknown field answer HTTP 400 with an
  empty envelope. The thrb pages report total 13 and the heho search reports total 3 of heho's
  41. In two live scans of 500 galleries each (start 0 and 8000 of 10,496), every gallery sends
  the same ten keys: `images` holds exactly one preview image of `{url, altText, title,
  description}` with no `caption`, `credit`, or `crops`; `assetCount` is a JSON integer, never
  zero in the scans; `tags` are strings, empty on 684 of 1,000; `relatedParks` is empty on 72 of
  1,000; and `copyright` is the same boilerplate text on every gallery. `constraintsInfo` is
  `{constraint, grantingRights}`, `Public domain` and `Unknown` on 999 of 1,000 and `Restrictions
  apply on use and/or reproduction` with `Unknown` on one; the set is open.
- The live photo gallery assets body uses the same envelope. `/multimedia/galleries/assets` accepts
  galleryId, id, parkCode, stateCode, q, sort, limit, and start. `sort=title` and `sort=-title` each
  answer HTTP 200 in the order named, while `sort=relevanceScore` and an unknown field answer HTTP
  400 with an empty envelope. The cowp pages report total 301, and `q=snow` narrows heho in IA from
  727 assets to 15. `galleryId=1FFC7EF8-155D-4519-3ECC-B652E2E95E20` reports total 2, equal to that
  gallery's `assetCount`; a comma list of two galleries returns the sum of their counts, a lowercase
  or unknown UUID returns 0, and a value that is not UUID-shaped, such as `zzzz`, is ignored and
  returns all 206,378 assets. `id` behaves the same way. The service returns one entry per gallery
  membership: the search page carries asset `F67A3393-6933-4650-9253-137B7A1887CF` twice, with
  ordinals 3 and 85 and two `gid` values in `permalinkUrl`, and no entry names its gallery in any
  other field. In two live scans of 500 assets each (start 0 and 150,000), every asset sends the
  same twelve keys and every `fileInfo` the same five; `fileSizeKb`, `widthPixels`, `heightPixels`,
  and `ordinal` are JSON integers, and `fileType` is `image/jpeg` on 985, `image/gif` on 12,
  `image/png` on 2, and `image/tiff` on one. `constraintsInfo` is `Public domain` with `Full` on
  845, `Public domain` with `Unknown` on 153, and `Restrictions apply on use and/or reproduction`
  with `Full` on 2; the set is open. `copyright` takes 9 distinct values, including the gallery
  boilerplate, photographer names, and one mis-encoded copyright sign kept as sent. `tags` are empty
  on 394 of 1,000, `credit` is empty on 536, and `relatedParks` is empty on 41 and holds more than
  one park on 4.
- The live people body uses the same envelope. `/people` accepts parkCode, stateCode, q, limit,
  and start. `sort=title` and `sort=lastName` each answer HTTP 400 with an empty envelope. The
  yell pages report total 4 and the frla search reports total 30. `latitude`, `longitude`, and
  `latLong` are always JSON strings: in a live scan of 500 people, 338 sent empty strings and 162
  sent decimal text such as `"42.32527319611405"` with `latLong` as
  `"{lat:42.32527319611405, long:-71.13226890563965}"`; the yell pages send empty strings and the
  frla search sends decimal text. `bodyText` is HTML (`<p>`, `<h3>`, `<ul>`) or, for some people,
  plain text. `quickFacts` elements are `{id, value, name}`, and an `id` names the fact type, such
  as `Significance`, not the row. `relatedOrganizations` elements are `{id, url, name}` and were
  populated on 10 of the 500. Every image carries `crops`; 277 of 500 were populated, each with
  `aspectRatio` as a string (`"0.8"`, `"1"`). `firstName`, `middleName`, and `lastName` can be
  empty strings, and `credit` was empty in every scanned person.
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
- Five contact values for the Afterbay campground in `campgrounds-search.json` were replaced: the
  contact email, the voice number in `contacts` and its repeat in `reservationInfo`, the fax
  number, and the after-hours number in `reservationInfo` now read `redacted@example.com` and 555
  placeholders in each value's original format. The listed sha256 is of the original download;
  the committed file's sha256 is
  `033439626a6f996008aa14b6468b8fb938402d81ccaff4817c6e1af0eea88e7b`, and after whitespace
  normalization it differs from the download only by these redactions.

NPS content and media retain their [upstream usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
No referenced image or media file is downloaded into these fixtures.
