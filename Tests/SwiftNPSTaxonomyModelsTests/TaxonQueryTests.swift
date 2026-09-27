import SwiftNPSDataTestSupport
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TaxonQueryTests {
  @Test("Invalid code text never changes namespace or loses digits")
  func invalidCodes() {
    for value in [
      "", "0", "-1", "2147483648", "99999999999999999999", "A", "1,2", " 81838", "８１８３８",
    ] {
      #expect(throws: TaxonomyValidationError.invalidCode) {
        try TaxonomyEndpoint.taxonSummary(code: value, kind: .nps)
      }
      #expect(throws: TaxonomyValidationError.invalidCode) {
        try TaxonomyEndpoint.taxonProfile(code: value, kind: .itis)
      }
    }
  }

  @Test("Paging rejects invalid provider Int32 bounds")
  func invalidPaging() {
    for size in [0, -1, Int(Int32.max) + 1] {
      #expect(throws: TaxonomyValidationError.invalidPageSize) {
        try TaxonSummaryQuery(
          paging: .page(size: size, startIndex: 0),
          search: .commonName("hawk", category: nil, source: nil))
      }
    }
    for index in [-1, Int(Int32.max) + 1] {
      #expect(throws: TaxonomyValidationError.invalidStartIndex) {
        try TaxonProfileQuery(
          paging: .page(size: 1, startIndex: index),
          search: .scientificName("Pandion", category: nil, source: nil))
      }
    }
  }

  @Test("Unsafe path inputs and empty filters fail locally")
  func invalidText() {
    for value in ["", " ", ".", "..", "A/B", "A\\B", "A%2FB", "A\n"] {
      #expect(throws: TaxonomyValidationError.invalidSearchText) {
        try TaxonSummaryQuery(search: .commonName(value, category: nil, source: nil))
      }
    }
    #expect(throws: TaxonomyValidationError.invalidSearchText) {
      try TaxonProfileQuery(search: .scientificName("Pandion", category: "", source: nil))
    }
    #expect(throws: TaxonomyValidationError.invalidSearchText) {
      try TaxonProfileQuery(search: .scientificName("Pandion", category: nil, source: "\u{0}"))
    }
  }

  @Test("Names filters and wildcards retain exact encoded meaning")
  func namesAndFilters() throws {
    let query = try TaxonSummaryQuery(
      paging: .page(size: 1, startIndex: 0),
      search: .commonName("hawk é*, red", category: "Bird &?", source: "ITIS"))
    let request = NPSTaxonomyRequest.taxonSummariesResponse(query: query)
    #expect(
      request.endpoint.path
        == "/searchByCommonName/hawk%20%C3%A9%2A%2C%20red?category=Bird%20%26%3F&detail=basic&format=json&pageSize=1&source=ITIS&startIndex=0"
    )
    let profile = try TaxonProfileQuery(
      deriveIfBroken: true, paging: .all,
      search: .scientificName("Pandion haliaetus", category: nil, source: nil))
    #expect(
      NPSTaxonomyRequest.taxonProfilesResponse(query: profile).endpoint.path
        == "/searchByScientificName/Pandion%20haliaetus?deriveIfBroken=true&detail=profile&format=json"
    )
  }

  @Test("Single lookup always encodes namespace and representation")
  func singleLookup() throws {
    #expect(
      try TaxonomyEndpoint.taxonSummary(code: "00081838", kind: .nps).path
        == "/00081838?codeType=taxoncode&detail=basic&format=json")
    #expect(
      try TaxonomyEndpoint.taxonProfile(code: "81838", kind: .itis).path
        == "/81838?codeType=tsn&deriveIfBroken=false&detail=profile&format=json")
    let query = try TaxonSummaryQuery(
      paging: .page(size: Int(Int32.max), startIndex: Int(Int32.max)),
      search: .commonName("hawk", category: nil, source: nil))
    #expect(
      NPSTaxonomyRequest.taxonSummariesResponse(query: query).endpoint.path.hasSuffix(
        "pageSize=2147483647&startIndex=2147483647"))
  }
}
