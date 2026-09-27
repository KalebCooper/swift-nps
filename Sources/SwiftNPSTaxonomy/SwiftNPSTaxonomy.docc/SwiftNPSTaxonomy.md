# ``SwiftNPSTaxonomy``

Fetch NPS taxonomy records without a Data API key.

## Overview

The service base is `https://irmaservices.nps.gov/taxonomy/v2/rest`. Each operation has a client convenience, constrained request factory and typed endpoint.

```swift
import SwiftNPSTaxonomy
import SwiftNPSTaxonomyModels

let client = NPSTaxonomyClient()
let taxon = try await client.taxonSummary(code: "81838", kind: .nps)
```

## Shapes and namespaces

Single-code lookup requires `TaxonCodeKind.nps` (taxoncode) or `.itis` (TSN). The text "81838" selects Pandion haliaetus in NPS and Bankia schrencki in ITIS. Positive ASCII codes must fit Int32; leading zeros remain unchanged. NPSpecies TaxaCode uses the NPS namespace; no automatic join is performed.

Basic results use NPSTaxonSummary: CommonNames is optional text and the measured key is Kingdom. Profiles use NPSTaxonProfile: CommonNames is a nullable array, OrderedHierarchy is an array, and AcceptedTaxa, Synonyms and Crosswalks can be omitted. Related entries use ScientificName and preserve raw rank strings. Populated crosswalks were not observed in the bounded recordings; their declared shared-entry shape has synthetic decoding coverage only. Source URLs remain raw data and are never followed automatically.

## Name searches

TaxonSummaryQuery and TaxonProfileQuery take a common or scientific name, optional raw category/source filters and TaxonomyPaging. The default `.all` omits paging parameters; `.page(size:startIndex:)` requests one bounded response. These operations return bare arrays without totals. Profile queries explicitly send deriveIfBroken, defaulting to false.

Names and filters are percent encoded without trimming or case conversion. Literal wildcard text is retained, but the provider can reject it (a recorded encoded asterisk returned HTTP400). Invalid local text and out-of-range numeric inputs fail before I/O.

## Classification metadata

Sources have three distinct representations: basic list, profile list/single record, and trees containing categories/ranks. Use sourceCategories and sourceRanks to retrieve those individual lists. Categories have separate basic-list and profile-single shapes; ranks use one shape. taxonomyOptions exposes category, codeType, detail, paging and source guidance as raw value/description pairs. Unknown classifications and lifecycle strings remain open. Empty searches return arrays; unknown metadata objects can return HTTP404.

## Execution and errors

Single responses delegate through value(for:) and send(_:). Inject an HTTPCore Transport; the Apple convenience initializer uses URLSession. Redirects are disabled, no credentials are added, and NPSTaxonomyError preserves HTTP bytes/status/headers, decoding, transport and cancellation failures. No retries, caching or snapshot guarantees are provided.

## Topics

### Client and failures

- ``NPSTaxonomyClient``
- ``NPSTaxonomyError``
