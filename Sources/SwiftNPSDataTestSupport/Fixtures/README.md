# Recorded responses

Recorded from the NPS Data API on September 13, 2026 using the application identity
`(swift-nps, https://github.com/KalebCooper/swift-nps)`. These are real response bodies,
not examples copied from the specification. Tests read them locally and never contact NPS.

| File | Exact request | HTTP status |
| --- | --- | --- |
| api-key-missing.json | GET https://developer.nps.gov/api/v1/parks?parkCode=acad&limit=1&start=0 without an API key | 403 |
| parks-acad.json | GET https://developer.nps.gov/api/v1/parks?parkCode=acad&limit=1&start=0 | 200 |
| parks-beyond.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=2 | 200 |
| parks-empty.json | GET https://developer.nps.gov/api/v1/parks?parkCode=zzzz&limit=1&start=0 | 200 |
| parks-page-first.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=0 | 200 |
| parks-page-last.json | GET https://developer.nps.gov/api/v1/parks?limit=1&parkCode=acad,yell&sort=parkCode&start=1 | 200 |
| parks-search.json | GET https://developer.nps.gov/api/v1/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA | 200 |
| parks-yell.json | GET https://developer.nps.gov/api/v1/parks?parkCode=yell&limit=1&start=0 | 200 |

Successful recordings used the service's public demonstration credential in the `X-Api-Key`
header. No request headers or credentials are stored. The missing-key recording deliberately
omitted that header. Response ordering is retained, rather than alphabetized, to preserve the
provider's representation.

JSON whitespace is normalized to LF without trailing blanks. The Unicode em dash in Yellowstone
is written as the JSON escape `\u2014` to satisfy repository text rules. Decoded JSON was compared
with the original downloads and is identical. No data, nulls, fields, identifiers, or values were
invented or removed.

The pagination and search recordings additionally escape non-ASCII characters using JSON Unicode
escapes. Their decoded values were compared with the downloads and are identical.

SHA-256 of the original downloaded bodies, before whitespace normalization and lossless escaping:

| File | SHA-256 |
| --- | --- |
| api-key-missing.json | adf24054a0da1d216699be8c128aa47c2c98f381a2c21945836ebc904653c8cc |
| parks-acad.json | 190b90f17bff221b71e564247b265a581844143b4eeca8455674ad47154f4632 |
| parks-beyond.json | bc6e94934ea41746830b8df13e264efc9eef42d9fe23ace5e61d81c6d728996d |
| parks-empty.json | 1ad0336e6b3c625d4a2b4107f727d7060e449f1f9bf484d0c94933ff8f9bac6c |
| parks-page-first.json | bdf759dc187c206a91cb7b90ac5f667c2329de3734a4ede7bd20b37f1e82239d |
| parks-page-last.json | 76e1eeea6fde0f15c64aab4f073f068002f1dde043b332aa197725798da0f8d2 |
| parks-search.json | 1302400226103d947077e3d10908462b433ffc6b1e69511807af852640a67009 |
| parks-yell.json | 243bbc33c1ffee6ff2d86794e2b546d32da28c9a9f605449aa2e88968697b53d |

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
- The guide supports `X-Api-Key` as well as the query key represented in the Swagger security
  definition. The SDK uses the header exclusively and refuses redirects.
- The guide documents HTTP 429 for rate limiting, and limits can vary. The public demonstration
  credential reported a limit of 10 for these recordings. No rate-limit response was forced.
- Constructed edge cases in test source cover malformed data, unknown values, and status
  failures; they are explicitly separate from these recordings.

NPS content and media retain their [upstream usage terms](https://www.nps.gov/aboutus/disclaimer.htm).
No referenced image or media file is downloaded into these fixtures.
