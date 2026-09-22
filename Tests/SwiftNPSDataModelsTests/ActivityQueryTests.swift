import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Activities queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ActivityQueryTests {
  @Test("All documented activities parameters preserve caller values")
  func allDocumentedActivitiesParametersPreserveCallerValues() throws {
    let query = try ActivityQuery(
      identifiers: [NPSIdentifier("B2"), NPSIdentifier("A1")], limit: 2,
      parkCodes: [ParkCode("DRTO"), ParkCode("cwdw")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("id")], start: 3)
    #expect(
      Endpoint.activities(query: query).path
        == "/activities?id=B2,A1&limit=2&parkCode=DRTO,cwdw&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,id&start=3")
    #expect(Endpoint.collection(query) == Endpoint.activities(query: query))
  }

  @Test("Default activities queries explicitly request fifty results at zero")
  func defaultActivitiesQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.activities(query: ActivityQuery()).path == "/activities?limit=50&start=0")
    #expect(
      try Endpoint.activities(query: ActivityQuery(searchText: "")).path
        == "/activities?limit=50&q=&start=0")
  }

  @Test("Empty activities identifier, code, and sort arrays omit their parameters")
  func emptyActivitiesIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ActivityQuery(identifiers: [], limit: 1, parkCodes: [], sort: [])
    #expect(Endpoint.activities(query: query).path == "/activities?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid activities query pagination is rejected")
  func invalidActivitiesQueryPaginationIsRejected() {
    #expect(throws: ActivityQuery.ValidationError.invalidLimit) {
      try ActivityQuery(limit: 0)
    }
    #expect(throws: ActivityQuery.ValidationError.invalidLimit) {
      try ActivityQuery(limit: -1)
    }
    #expect(throws: ActivityQuery.ValidationError.invalidStart) {
      try ActivityQuery(start: -1)
    }
  }

  @Test("Activities sort fields are sent without validation or reordering")
  func activitiesSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try ActivityQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.activities(query: query).path
        == "/activities?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("Activities requests resolve as collections of the same query")
  func activitiesRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ActivityQuery(limit: 1, parkCodes: [ParkCode("drto")])
    let request = NPSDataRequest.activities(query: query)
    let _: NPSDataRequest<NPSCollection<Activity>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .activities(query: query)]).count == 1)
    #expect(request != .activities(query: try ActivityQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.activities(query: query))
    #expect(resolution.query as? ActivityQuery == query)
  }

  @Test("The recorded requests match the activities query paths")
  func theRecordedRequestsMatchTheActivitiesQueryPaths() throws {
    let fishing = "AE42B46C-E4B7-4889-A122-08FE180371AE"
    let wildlife = "0B685688-3405-4E2A-ABBA-E3069492EC50"
    let search = try ActivityQuery(
      limit: 2, parkCodes: [ParkCode("cwdw"), ParkCode("drto")], searchText: "tours",
      sort: [.descending("name")])
    #expect(
      Endpoint.activities(query: search).path
        == "/activities?limit=2&parkCode=cwdw,drto&q=tours&sort=-name&start=0")
    let page = try ActivityQuery(
      identifiers: [NPSIdentifier(fishing), NPSIdentifier(wildlife)], limit: 1,
      parkCodes: [ParkCode("drto")], sort: [.descending("name")])
    #expect(
      Endpoint.activities(query: page).path
        == "/activities?id=\(fishing),\(wildlife)&limit=1&parkCode=drto&sort=-name&start=0")
    #expect(
      Endpoint.activities(query: page.starting(at: 1)).path
        == "/activities?id=\(fishing),\(wildlife)&limit=1&parkCode=drto&sort=-name&start=1")
    let empty = try ActivityQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.activities(query: empty).path == "/activities?limit=1&parkCode=zzzz&start=0")
  }

  @Test("An activities query advances by the returned item count and keeps its filters")
  func anActivitiesQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ActivityQuery(
      identifiers: [NPSIdentifier("A1"), NPSIdentifier("B2")], limit: 1,
      parkCodes: [ParkCode("drto")], searchText: "watching",
      sort: [.descending("name"), .ascending("id")], start: 0)
    let page = try JSONDecoder().decode(
      NPSCollection<Activity>.self, from: Fixture.activitiesPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.activities(query: next).path
        == "/activities?id=A1,B2&limit=1&parkCode=drto&q=watching&sort=-name,id&start=1")
  }
}
