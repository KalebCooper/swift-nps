import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Activity parks queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkActivityParksQueryTests {
  @Test("All documented activity parks parameters preserve caller values")
  func allDocumentedActivityParksParametersPreserveCallerValues() throws {
    let query = try ParkActivityParksQuery(
      identifiers: [NPSIdentifier("B2"), NPSIdentifier("A1")], limit: 2,
      parkCodes: [ParkCode("DRTO"), ParkCode("cwdw")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("id")], start: 3)
    #expect(
      Endpoint.parkActivityParks(query: query).path
        == "/activities/parks?id=B2,A1&limit=2&parkCode=DRTO,cwdw&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,id&start=3")
    #expect(Endpoint.collection(query) == Endpoint.parkActivityParks(query: query))
  }

  @Test("Default activity parks queries explicitly request fifty results at zero")
  func defaultActivityParksQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.parkActivityParks(query: ParkActivityParksQuery()).path
        == "/activities/parks?limit=50&start=0")
    #expect(
      try Endpoint.parkActivityParks(query: ParkActivityParksQuery(searchText: "")).path
        == "/activities/parks?limit=50&q=&start=0")
  }

  @Test("Empty activity parks identifier, code, and sort arrays omit their parameters")
  func emptyActivityParksIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ParkActivityParksQuery(identifiers: [], limit: 1, parkCodes: [], sort: [])
    #expect(Endpoint.parkActivityParks(query: query).path == "/activities/parks?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid activity parks query pagination is rejected")
  func invalidActivityParksQueryPaginationIsRejected() {
    #expect(throws: ParkActivityParksQuery.ValidationError.invalidLimit) {
      try ParkActivityParksQuery(limit: 0)
    }
    #expect(throws: ParkActivityParksQuery.ValidationError.invalidLimit) {
      try ParkActivityParksQuery(limit: -1)
    }
    #expect(throws: ParkActivityParksQuery.ValidationError.invalidStart) {
      try ParkActivityParksQuery(start: -1)
    }
  }

  @Test("Activity parks sort fields are sent without validation or reordering")
  func activityParksSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses parkCode with HTTP 400; the query still sends it as named.
    let query = try ParkActivityParksQuery(
      limit: 1, sort: [.descending("parkCode"), .ascending("futureField")])
    #expect(
      Endpoint.parkActivityParks(query: query).path
        == "/activities/parks?limit=1&sort=-parkCode,futureField&start=0")
  }

  @Test("Activity parks requests resolve as collections of the same query")
  func activityParksRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkActivityParksQuery(limit: 1, parkCodes: [ParkCode("drto")])
    let request = NPSDataRequest.parkActivityParks(query: query)
    let _: NPSDataRequest<NPSCollection<ParkActivityParks>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkActivityParks(query: query)]).count == 1)
    #expect(request != .parkActivityParks(query: try ParkActivityParksQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkActivityParks(query: query))
    #expect(resolution.query as? ParkActivityParksQuery == query)
  }

  @Test("The recorded requests match the activity parks query paths")
  func theRecordedRequestsMatchTheActivityParksQueryPaths() throws {
    let fishing = "AE42B46C-E4B7-4889-A122-08FE180371AE"
    let tours = "B33DC9B6-0B7D-4322-BAD7-A13A34C584A3"
    let wildlife = "0B685688-3405-4E2A-ABBA-E3069492EC50"
    let search = try ParkActivityParksQuery(
      identifiers: [NPSIdentifier(tours), NPSIdentifier(wildlife)], limit: 2,
      parkCodes: [ParkCode("cwdw"), ParkCode("drto")], searchText: "tours",
      sort: [.descending("name")])
    #expect(
      Endpoint.parkActivityParks(query: search).path
        == "/activities/parks?id=\(tours),\(wildlife)&limit=2&parkCode=cwdw,drto&q=tours"
        + "&sort=-name&start=0")
    let page = try ParkActivityParksQuery(
      identifiers: [NPSIdentifier(fishing), NPSIdentifier(wildlife)], limit: 1,
      parkCodes: [ParkCode("drto")], sort: [.descending("name")])
    #expect(
      Endpoint.parkActivityParks(query: page).path
        == "/activities/parks?id=\(fishing),\(wildlife)&limit=1&parkCode=drto&sort=-name&start=0")
    #expect(
      Endpoint.parkActivityParks(query: page.starting(at: 1)).path
        == "/activities/parks?id=\(fishing),\(wildlife)&limit=1&parkCode=drto&sort=-name&start=1")
    let empty = try ParkActivityParksQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.parkActivityParks(query: empty).path
        == "/activities/parks?limit=1&parkCode=zzzz&start=0")
  }

  @Test("An activity parks query advances by the returned item count and keeps its filters")
  func anActivityParksQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ParkActivityParksQuery(
      identifiers: [NPSIdentifier("A1"), NPSIdentifier("B2")], limit: 1,
      parkCodes: [ParkCode("drto")], searchText: "watching",
      sort: [.descending("name"), .ascending("id")], start: 0)
    let page = try JSONDecoder().decode(
      NPSCollection<ParkActivityParks>.self, from: Fixture.activityParksPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.parkActivityParks(query: next).path
        == "/activities/parks?id=A1,B2&limit=1&parkCode=drto&q=watching&sort=-name,id&start=1")
  }
}
