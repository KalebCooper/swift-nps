import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Parks queries and continuation", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkQueryTests {
  @Test("All documented query parameters preserve caller values")
  func allDocumentedQueryParametersPreserveCallerValues() throws {
    let query = try ParkQuery(
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é",
      sort: [.fullName(.descending), .parkCode(.ascending)], start: 3,
      stateCodes: [StateCode("me"), StateCode("MA")])
    #expect(
      Endpoint.parks(query: query).path
        == "/parks?limit=2&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9&sort=-fullName,parkCode&start=3&stateCode=me,MA"
    )
    let request = ParkRequest.parks(query: query)
    let _: ParkRequest<ParksResponse> = request
    #expect(request.resolution == .parks(query))
    #expect(Set([request, .parks(query: query)]).count == 1)
  }

  @Test("Default queries explicitly request fifty results at zero")
  func defaultQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.parks(query: ParkQuery()).path == "/parks?limit=50&start=0")
    #expect(
      try Endpoint.parks(query: ParkQuery(searchText: "")).path == "/parks?limit=50&q=&start=0")
  }

  @Test(
    "Invalid pagination metadata fails explicitly",
    arguments: [
      ("limit", "0"), ("limit", "-1"), ("start", "+0"), ("total", ""),
      ("total", "1.5"), ("total", " 2"), ("total", "999999999999999999999999999"),
    ])
  func invalidPaginationMetadataFailsExplicitly(_ field: String, _ value: String) throws {
    let page = try modifiedPage([field: value])
    #expect(throws: ParkPaginationError.invalidMetadata(field: field, value: value)) {
      try ParkQuery(limit: 1).next(after: page)
    }
  }

  @Test("Invalid query pagination and mixed relevance sorting are rejected")
  func invalidQueryPaginationAndMixedRelevanceSortingAreRejected() {
    #expect(throws: ParkQuery.ValidationError.invalidLimit) { try ParkQuery(limit: 0) }
    #expect(throws: ParkQuery.ValidationError.invalidLimit) { try ParkQuery(limit: -1) }
    #expect(throws: ParkQuery.ValidationError.invalidStart) { try ParkQuery(start: -1) }
    #expect(throws: ParkQuery.ValidationError.mixedRelevanceSort) {
      try ParkQuery(sort: [.relevanceScore(.descending), .fullName(.ascending)])
    }
  }

  @Test("Offset overflow is reported without wrapping")
  func offsetOverflowIsReportedWithoutWrapping() throws {
    let page = try modifiedPage(["start": String(Int.max), "total": String(Int.max)])
    #expect(throws: ParkPaginationError.offsetOverflow) {
      try ParkQuery(start: Int.max).next(after: page)
    }
  }

  @Test("Recorded pages advance without changing query options")
  func recordedPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(ParksResponse.self, from: Fixture.parksPageFirst.data())
    let last = try JSONDecoder().decode(ParksResponse.self, from: Fixture.parksPageLast.data())
    let query = try ParkQuery(
      limit: 1, parkCodes: [ParkCode("acad"), ParkCode("yell")], searchText: "park",
      sort: [.parkCode(.ascending)], stateCodes: [StateCode("ME"), StateCode("WY")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "park")
    #expect(following.sort == [.parkCode(.ascending)])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last) == nil)
    let beyond = try JSONDecoder().decode(ParksResponse.self, from: Fixture.parksBeyond.data())
    #expect(try ParkQuery(start: 2).next(after: beyond) == nil)
  }

  @Test("Recorded search results retain relevance and multiple-state filtering")
  func recordedSearchResultsRetainRelevanceAndMultipleStateFiltering() throws {
    let page = try JSONDecoder().decode(ParksResponse.self, from: Fixture.parksSearch.data())
    #expect(page.data.map(\.parkCode) == ["adam", "bost"])
    #expect(page.data.map(\.relevanceScore) == [9.226259, 9.226259])
    #expect(page.total == "21")
    let query = try ParkQuery(
      limit: 2, searchText: "history", sort: [.relevanceScore(.descending)],
      stateCodes: [StateCode("ME"), StateCode("MA")])
    #expect(
      Endpoint.parks(query: query).path
        == "/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA")
    #expect(try query.next(after: page)?.start == 2)
  }

  @Test("Short pages advance by returned count without skipping records")
  func shortPagesAdvanceByReturnedCountWithoutSkippingRecords() throws {
    let page = try modifiedPage(["limit": "50", "total": "3"])
    #expect(try ParkQuery().next(after: page)?.start == 1)
  }

  @Test("State codes preserve case and unknown values", arguments: ["ME", "ma", "ZZ"])
  func stateCodesPreserveCaseAndUnknownValues(_ value: String) throws {
    #expect(try StateCode(value).rawValue == value)
  }

  @Test("State codes reject invalid syntax", arguments: ["", "M", "MAA", "M1", "MÉ", " MA", "M,"])
  func stateCodesRejectInvalidSyntax(_ value: String) {
    #expect(throws: StateCode.ValidationError.invalidValue) { try StateCode(value) }
  }

  @Test("Unexpected offsets and contradictory counts cannot imply completion")
  func unexpectedOffsetsAndContradictoryCountsCannotImplyCompletion() throws {
    let repeated = try modifiedPage([:])
    #expect(throws: ParkPaginationError.unexpectedStart(actual: 0, expected: 1)) {
      try ParkQuery(start: 1).next(after: repeated)
    }
    let premature = try modifiedPage(["data": []])
    #expect(throws: ParkPaginationError.inconsistentPage) { try ParkQuery().next(after: premature) }
    let contradictory = try modifiedPage(["total": "0"])
    #expect(throws: ParkPaginationError.inconsistentPage) {
      try ParkQuery().next(after: contradictory)
    }
  }

  private func modifiedPage(_ changes: [String: Any]) throws -> ParksResponse {
    // Constructed metadata cases are deliberately separate from the recorded response bodies.
    var object = try #require(
      JSONSerialization.jsonObject(with: Fixture.parksPageFirst.data()) as? [String: Any])
    object.merge(changes) { _, new in new }
    return try JSONDecoder().decode(
      ParksResponse.self, from: JSONSerialization.data(withJSONObject: object))
  }
}
