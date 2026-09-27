# IRMA implementation

The unreleased IRMA implementation adds five independent SDK/Models pairs alongside the existing Data API pair. Its scoped inventory is **52 GET paths and one read-only POST operation**. Each operation has a client convenience, an inspectable request and a typed endpoint. Models have no package dependencies.

The services remain independent because their identifiers, response shapes and continuation rules differ. IRMA requests use no Data API key, stay within their service base, and refuse redirects. There are no automatic joins, retries, caching, inferred availability or manufactured freshness guarantees.

## Scoped inventory

Paths below are relative to each service's fixed base. Client operation names also identify their request and endpoint factories, except Species XML discovery which uses its own concrete request/endpoint types. Original fixture provenance is in [Fixtures/README.md](Sources/SwiftNPSDataTestSupport/Fixtures/README.md).

| Service / base | Included GET paths | Public operations |
| --- | --- | --- |
| Landmarks: `https://irmaservices.nps.gov/NNLApi/v1` | `/api/AllStates`, `/api/State`, `/api/County` | landmarkStates, landmarkState, landmarkCounty |
| Landmarks | `/api/SiteCounties`, `/api/StateCounty`, `/api/StatesAndLandmarks` | landmarkSiteCounties, landmarkStateCounties, statesAndLandmarks |
| Landmarks | `/api/LandmarkInformationPerStateCode`, `/api/LandmarkInformationPerCounty`, `/api/LandmarkInformation`, `/api/LandmarkInformationWithCounty`, `/api/LandmarkOwnerInformation` | landmarks(stateCode:), landmarks(countyID:), landmarks(query:), landmarksWithCounty, landmarkOwners |
| Species: `https://irmaservices.nps.gov/NPSpecies/v3/rest` | `/checklist/{unitCode}/{categories}`, `/detaillist/{unitCode}/{categories}`, `/fulllist/{unitCode}/{categories}` | speciesChecklist, speciesDetails, species |
| Species | `/urlOptions/categories` | categoryOptions (XML) |
| Taxonomy: `https://irmaservices.nps.gov/taxonomy/v2/rest` | `/{code}`, `/searchByCommonName/{text}`, `/searchByScientificName/{text}`, `/searchByCodes/{codeType}` | taxonSummary, taxonProfile, taxonSummariesResponse, taxonProfilesResponse |
| Taxonomy | `/sources`, `/sources/{code}`, `/sources/tree`, `/sources/tree/{code}`, `/sources/{code}/categories`, `/sources/{code}/ranks` | taxonomicSources, taxonomicSourceProfiles, taxonomicSource, taxonomicSourceTrees, taxonomicSourceTree, sourceCategories, sourceRanks |
| Taxonomy | `/categories`, `/categories/{code}`, `/ranks`, `/ranks/{code}` | taxonomicCategories, taxonomicCategory, taxonomicRanks, taxonomicRank |
| Taxonomy | `/urlOptions/category`, `/urlOptions/codeType`, `/urlOptions/detail`, `/urlOptions/paging`, `/urlOptions/source` | taxonomyOptions |
| Units: `https://irmaservices.nps.gov/Unit/v2/api` | `/`, `/{searchTerm}` | units, units(matching:) |
| Units | `/{unitcode}/linked`, `/{unitcode}/linked/functional`, `/{unitcode}/linked/logical` | linkedUnits with explicit UnitLinkKind |
| Units | `/collections`, `/designations`, `/designations/{designation}`, `/subtypes`, `/subtypes/{subtype}` | unitCollections, unitDesignations, unitDesignation, unitSubtypes, unitSubtype |
| Units | `/{searchTerm}/geography`, `/states`, `/states/{state}`, `/states/{state}/{county}`, `/unitpoints`, `/unitselector` | unitGeographies, unitStates, unitState, unitCounty, unitPoints, unitSelector |
| Visitation: `https://irmaservices.nps.gov/v3/rest/stats` | `/visitation`, `/total/{year}` | visitation, nationalVisitation |

Taxonomy additionally supports POST `/searchByCodes/{codeType}` with a JSON string array. Callers explicitly choose GET or POST; no URL-length heuristic changes it. Each representation has lazy page/item conveniences over HTTPClient.pages. Pure Models continuation advances by returned count, stops only on empty, and rejects oversized pages or Int32 overflow before yielding. All-mode requests return a single response and cannot start lazy traversal; endpoint-only requests yield once.

Excluded from the scope: duplicate Landmarks POST forms, schema/help/documentation routes, format-discovery variants, write operations, geometry conversion, automatic species/taxonomy joins, and the Data API's separate authenticated route inventory. This count does not claim every URL exposed by IRMA.

## Contract distinctions

- Landmarks State and County are objects; StatesAndLandmarks is a flat repeated-membership index. CountyID differs from landmark ID, and enriched rows can contain zero CountyID with null labels. Designation implies neither public access nor NPS ownership.
- Species checklist, full and detail lists retain distinct membership. Category discovery is XML despite a JSON format request. Raw aliases, unknown classifications and original text remain intact.
- Taxonomy always distinguishes NPS codes from ITIS TSNs. Basic CommonNames is optional text; profile CommonNames is a nullable array. Related ScientificName and rank strings remain raw, and external links are data only. Populated crosswalks were not observed in bounded probes; their declared shared-entry shape has synthetic coverage only.
- Unit codes are administrative identifiers, FIPS values remain strings, selector numeric lifecycle values remain distinct from profile strings, and geography stays raw WKT/GML.
- Visitation preserves missing months, national null identifiers and Int64 counts without invented zeros or aggregation.

## Products and documentation

Each service has `SwiftNPS<Service>` and `SwiftNPS<Service>Models` products, tests, original fixtures, and two DocC catalogs. The existing SwiftNPSData/SwiftNPSDataModels products remain available. All twelve catalogs are included in the documentation workflow and Swift Package Index configuration. Each Models archive is staged before its SDK, and missing archives or link metadata fail the workflow.

Swift tools 6.2, Swift 6 and Apple 26 platform floors remain unchanged. Every target retains the shared isolation, nonsending and strict memory settings. swift-http-types 1.6.0 and swifty-networking 1.1.0 remain the minimum dependencies. Default traits are empty, HTTPPortable is conditional, and HTTPURLSession is Apple-only. Test support is not a consumer product.

## Local qualification

Local checks on September 27, 2026:

| Check | Result |
| --- | --- |
| Independent source and inventory review | No unresolved correctness findings |
| macOS 27 and iOS 27 simulator, Xcode MCP | 1,081 tests passed on each destination; no skips or failures |
| Linux, default and HTTPPortable | 743 tests in 117 suites passed in each configuration |
| Static checks and verification-script self-tests | Passed, including all 51 self-test arms |
| Consumer compilation | All twelve products together, contextual request factories, and five isolated Models-only custom executors passed |
| DocC | All twelve catalogs built with warnings treated as errors; link metadata checked and archives merged locally |
| Default Apple dependency graph | No HTTPPortable or NIO targets; six Models targets have no dependencies |
| Release demo | MCP build passed; all five IRMA service entries and normal responses, cancellation, invalid/empty/error results, and taxonomy paging/reset passed. Data API key gating and live Events loading/pagination also passed |

Release compilation reports a strict-memory-safety warning on Apple's XMLParser delegate assignment. The delegate is strongly held and read after synchronous parsing; review found no lifetime defect. The warning remains disclosed without suppression. Apple test linking has also emitted toolchain sysroot warnings. Documentation builds have no warnings.

Android runtime verification is explicitly deferred and unverified; no Android portability claim is made for the new IRMA implementation. Populated logical unit links and taxonomy crosswalks were not observed in bounded live probes. Empty logical links have original fixtures; populated crosswalk decoding has synthetic coverage, distinguished from provider evidence.

Release UI verification exercised ACAD visitation, Species birds and XML category discovery, unit lookup and all profiles, APBO-ME landmarks, and NPS/ITIS taxonomy lookup. Species cancellation remained cancelled without stale results. Taxonomy profiles showed no raw citation HTML; GET and POST batches each advanced from one to three records before an empty terminal page removed Load more and retained existing rows. Namespace, representation, method, page size, category and search edits reset results. Common-name paging, an impossible-name empty response, invalid numeric input and a provider category error were also observed.

The work is local and unreleased. No push, tag, hosted qualification, Pages publication or release is part of this implementation.
