import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Parks queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkQueryTests {
  @Test("All documented query parameters preserve caller values")
  func allDocumentedQueryParametersPreserveCallerValues() throws {
    let query = try ParkQuery(
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é",
      sort: [.descending("fullName"), NPSSort("parkCode")], start: 3,
      stateCodes: [StateCode("me"), StateCode("MA")])
    #expect(
      Endpoint.parks(query: query).path
        == "/parks?limit=2&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9&sort=-fullName,parkCode&start=3&stateCode=me,MA"
    )
    #expect(Endpoint.collection(query) == Endpoint.parks(query: query))
    let request = NPSDataRequest.parks(query: query)
    let _: NPSDataRequest<NPSCollection<Park>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parks(query: query)]).count == 1)
  }

  @Test("Collection requests erase queries without closures and stay inspectable")
  func collectionRequestsEraseQueriesWithoutClosuresAndStayInspectable() throws {
    let query = try ParkQuery(limit: 1, parkCodes: [ParkCode("acad"), ParkCode("yell")])
    let request = NPSDataRequest.parks(query: query)
    #expect(request == .parks(query: query))
    #expect(request.hashValue == NPSDataRequest.parks(query: query).hashValue)
    #expect(request != .parks(query: try ParkQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parks(query: query))
    #expect(resolution.query as? ParkQuery == query)
    let empty = Data(#"{"data":[],"limit":"1","start":"0","total":"0"}"#.utf8)
    let page = try JSONDecoder().decode(NPSCollection<Park>.self, from: empty)
    #expect(try resolution.next(after: page) == nil)
    let body = try Fixture.parksPageFirst.data()
    let first = try JSONDecoder().decode(NPSCollection<Park>.self, from: body)
    let following = try #require(try resolution.next(after: first))
    #expect(following.endpoint == Endpoint.parks(query: query.starting(at: 1)))
    #expect(following.query as? ParkQuery == query.starting(at: 1))
  }

  @Test("Default queries explicitly request fifty results at zero")
  func defaultQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.parks(query: ParkQuery()).path == "/parks?limit=50&start=0")
    #expect(
      try Endpoint.parks(query: ParkQuery(searchText: "")).path == "/parks?limit=50&q=&start=0")
  }

  @Test("Invalid query pagination and mixed relevance sorting are rejected")
  func invalidQueryPaginationAndMixedRelevanceSortingAreRejected() {
    #expect(throws: ParkQuery.ValidationError.invalidLimit) { try ParkQuery(limit: 0) }
    #expect(throws: ParkQuery.ValidationError.invalidLimit) { try ParkQuery(limit: -1) }
    #expect(throws: ParkQuery.ValidationError.invalidStart) { try ParkQuery(start: -1) }
    #expect(throws: ParkQuery.ValidationError.mixedRelevanceSort) {
      try ParkQuery(sort: [.descending("relevanceScore"), .ascending("fullName")])
    }
  }

  @Test("Recorded search results retain relevance and multiple-state filtering")
  func recordedSearchResultsRetainRelevanceAndMultipleStateFiltering() throws {
    let page = try JSONDecoder().decode(NPSCollection<Park>.self, from: Fixture.parksSearch.data())
    #expect(page.data.map(\.parkCode) == ["adam", "bost"])
    #expect(page.data.map(\.relevanceScore) == [9.226259, 9.226259])
    #expect(page.total == "21")
    let query = try ParkQuery(
      limit: 2, searchText: "history", sort: [.descending("relevanceScore")],
      stateCodes: [StateCode("ME"), StateCode("MA")])
    #expect(
      Endpoint.parks(query: query).path
        == "/parks?limit=2&q=history&sort=-relevanceScore&start=0&stateCode=ME,MA")
    #expect(try query.next(after: page)?.start == 2)
  }

  @Test("State codes preserve case and unknown values", arguments: ["ME", "ma", "ZZ"])
  func stateCodesPreserveCaseAndUnknownValues(_ value: String) throws {
    #expect(try StateCode(value).rawValue == value)
  }

  @Test("State codes reject invalid syntax", arguments: ["", "M", "MAA", "M1", "MÉ", " MA", "M,"])
  func stateCodesRejectInvalidSyntax(_ value: String) {
    #expect(throws: StateCode.ValidationError.invalidValue) { try StateCode(value) }
  }
}
