import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park video queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkVideoQueryTests {
  @Test("All documented park video parameters preserve caller values")
  func allDocumentedParkVideoParametersPreserveCallerValues() throws {
    let query = try ParkVideoQuery(
      limit: 2, parkCodes: [ParkCode("CRMO"), ParkCode("boaf")], searchText: "a +&/#?é",
      sort: [.descending("title"), .ascending("durationMs")], start: 3,
      stateCodes: [StateCode("id"), StateCode("MA")])
    #expect(
      Endpoint.parkVideos(query: query).path
        == "/multimedia/videos?limit=2&parkCode=CRMO,boaf&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-title,durationMs&start=3&stateCode=id,MA")
    #expect(Endpoint.collection(query) == Endpoint.parkVideos(query: query))
  }

  @Test("Default park video queries explicitly request fifty results at zero")
  func defaultParkVideoQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.parkVideos(query: ParkVideoQuery()).path == "/multimedia/videos?limit=50&start=0"
    )
    #expect(
      try Endpoint.parkVideos(query: ParkVideoQuery(searchText: "")).path
        == "/multimedia/videos?limit=50&q=&start=0")
  }

  @Test("Empty code and sort arrays omit their parameters")
  func emptyCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ParkVideoQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.parkVideos(query: query).path == "/multimedia/videos?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid park video query pagination is rejected")
  func invalidParkVideoQueryPaginationIsRejected() {
    #expect(throws: ParkVideoQuery.ValidationError.invalidLimit) {
      try ParkVideoQuery(limit: 0)
    }
    #expect(throws: ParkVideoQuery.ValidationError.invalidLimit) {
      try ParkVideoQuery(limit: -1)
    }
    #expect(throws: ParkVideoQuery.ValidationError.invalidStart) {
      try ParkVideoQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try ParkVideoQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.parkVideos(query: query).path
        == "/multimedia/videos?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("Park video requests resolve as collections of the same query")
  func parkVideoRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkVideoQuery(limit: 1, parkCodes: [ParkCode("crmo")])
    let request = NPSDataRequest.parkVideos(query: query)
    let _: NPSDataRequest<NPSCollection<ParkVideo>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkVideos(query: query)]).count == 1)
    #expect(request != .parkVideos(query: try ParkVideoQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkVideos(query: query))
    #expect(resolution.query as? ParkVideoQuery == query)
  }

  @Test("The recorded requests match the park video query paths")
  func theRecordedRequestsMatchTheParkVideoQueryPaths() throws {
    let search = try ParkVideoQuery(
      limit: 2, parkCodes: [ParkCode("boaf")], searchText: "Boston",
      sort: [.ascending("title")], stateCodes: [StateCode("MA")])
    #expect(
      Endpoint.parkVideos(query: search).path
        == "/multimedia/videos?limit=2&parkCode=boaf&q=Boston&sort=title&start=0&stateCode=MA")
    let page = try ParkVideoQuery(limit: 1, parkCodes: [ParkCode("crmo")])
    #expect(
      Endpoint.parkVideos(query: page).path == "/multimedia/videos?limit=1&parkCode=crmo&start=0")
    #expect(
      Endpoint.parkVideos(query: page.starting(at: 1)).path
        == "/multimedia/videos?limit=1&parkCode=crmo&start=1")
    let empty = try ParkVideoQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.parkVideos(query: empty).path == "/multimedia/videos?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A park video query advances by the returned item count and keeps its filters")
  func aParkVideoQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ParkVideoQuery(
      limit: 1, parkCodes: [ParkCode("crmo")], sort: [.ascending("title")])
    let page = try JSONDecoder().decode(
      NPSCollection<ParkVideo>.self, from: Fixture.parkVideosPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(next == query.starting(at: 1))
    #expect(
      Endpoint.parkVideos(query: next).path
        == "/multimedia/videos?limit=1&parkCode=crmo&sort=title&start=1")
  }
}
