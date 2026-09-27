# ``SwiftNPSSpeciesModels``

Portable NPSpecies records, exact queries, and inspectable requests.

## Overview

Import this dependency-free product to decode the provider's three different lists or execute
requests using your own networking. Checklist membership differs from full and detailed lists.
Identifiers and taxon codes stay strings; formatted scientific names remain HTML text. Missing
status, count, and classification fields remain nil. ``SpeciesSynonym`` preserves the measured
synonym object shared by all three lists.

```swift
let query = try SpeciesQuery(categories: ["birds", "mammals"], unitCode: "ACAD")
let request = NPSSpeciesRequest.speciesChecklist(query: query)
print(request.endpoint.path)
```

Omit categories for all categories; the endpoint retains the required trailing slash.
Category order, duplicates, and spelling remain unchanged. An empty supplied list, leading/trailing whitespace,
controls, commas within entries, percent signs, path separators, and dot segments are rejected.
Category names may contain interior spaces, such as Vascular Plants; unit codes may not.
This prevents ambiguous path interpretation without imposing a closed category enum.

NPSpecies TaxaCode uses the NPS taxonomy namespace. It must not be treated as an ITIS TSN.
These records describe published inventories, not current wildlife presence or sightings.

## Topics

### Category reference

- ``SpeciesCategoriesEndpoint``
- ``SpeciesCategoriesRequest``
- ``SpeciesCategoryOption``

### Records

- ``SpeciesChecklistItem``
- ``SpeciesDetailItem``
- ``SpeciesItem``
- ``SpeciesSynonym``

### Queries and request descriptions

- ``NPSSpeciesRequest``
- ``SpeciesEndpoint``
- ``SpeciesQuery``
