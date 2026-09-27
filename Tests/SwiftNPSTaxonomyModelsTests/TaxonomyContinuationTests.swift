import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSTaxonomyModels
import Testing

@Suite("Taxonomy continuation", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TaxonomyContinuationTests {
  @Test("Batch inputs reject empty lists and preserve GET code order")
  func batchValidation() throws {
    for submission in [TaxonomySubmission.get, .post] {
      for codes in [[], [""], ["2147483648"], ["1,2"], ["١"]] {
        #expect(throws: TaxonomyValidationError.invalidCode) {
          try TaxonSummaryQuery(search: .codes(codes, kind: .itis, submission: submission))
        }
      }
    }
    let query = try TaxonSummaryQuery(
      search: .codes(["00081838", "1", "1"], kind: .nps, submission: .get))
    let endpoint = TaxonomyEndpoint.taxonSummariesResponse(query: query)
    #expect(
      endpoint.path == "/searchByCodes/taxoncode?codes=00081838%2C1%2C1&detail=basic&format=json")
    #expect(endpoint.method == .get && endpoint.body == nil)
  }

  @Test("Both representations reject all mode oversized pages and index overflow")
  func invalidContinuation() throws {
    let basic = try JSONDecoder().decode(
      NPSTaxonSummary.self, from: IRMAFixture.taxonomyBasicNPS.data())
    let profile = try JSONDecoder().decode(
      NPSTaxonProfile.self, from: IRMAFixture.taxonomy81838NPS.data())
    let search = TaxonSearch.codes(["81838"], kind: .nps, submission: .post)
    let allBasic = try TaxonSummaryQuery(search: search)
    let allProfile = try TaxonProfileQuery(search: search)
    #expect(throws: TaxonomyPaginationError.allModeUnavailable) { try allBasic.next(after: []) }
    #expect(throws: TaxonomyPaginationError.allModeUnavailable) { try allProfile.next(after: []) }
    let basicQuery = try TaxonSummaryQuery(
      paging: .page(size: 1, startIndex: Int(Int32.max)), search: search)
    let profileQuery = try TaxonProfileQuery(
      deriveIfBroken: true,
      paging: .page(size: 1, startIndex: Int(Int32.max)), search: search)
    #expect(throws: TaxonomyPaginationError.indexOverflow) { try basicQuery.next(after: [basic]) }
    #expect(throws: TaxonomyPaginationError.indexOverflow) {
      try profileQuery.next(after: [profile])
    }
    #expect(throws: TaxonomyPaginationError.oversizedPage) {
      try basicQuery.next(after: [basic, basic])
    }
    #expect(throws: TaxonomyPaginationError.oversizedPage) {
      try profileQuery.next(after: [profile, profile])
    }
    #expect(try basicQuery.next(after: []) == nil)
    #expect(try profileQuery.next(after: []) == nil)
    let next = try #require(try profileQuery.starting(at: 8).next(after: [profile]))
    #expect(
      next.deriveIfBroken && next.search == search && next.paging == .page(size: 1, startIndex: 9))
  }

  @Test("POST continuation retains the original JSON code array")
  func postContinuation() throws {
    let query = try TaxonSummaryQuery(
      paging: .page(size: 2, startIndex: 7),
      search: .codes(["81838", "000719252", "81838"], kind: .nps, submission: .post))
    let endpoint = TaxonomyEndpoint.taxonSummariesResponse(query: query)
    #expect(endpoint.method == .post)
    #expect(endpoint.body == Data(#"["81838","000719252","81838"]"#.utf8))
    let row = try JSONDecoder().decode(
      NPSTaxonSummary.self, from: IRMAFixture.taxonomyBasicNPS.data())
    let next = try #require(try query.next(after: [row]))
    #expect(next.paging == .page(size: 2, startIndex: 8))
    #expect(next.search == query.search)
    #expect(TaxonomyEndpoint.taxonSummariesResponse(query: next).body == endpoint.body)
    #expect(try next.next(after: []) == nil)
  }
}
