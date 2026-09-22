import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park fees and passes queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkFeesAndPassesQueryTests {
  @Test("All documented fees and passes parameters preserve caller values")
  func allDocumentedFeesAndPassesParametersPreserveCallerValues() throws {
    let query = try ParkFeesAndPassesQuery(
      limit: 2, parkCodes: [ParkCode("HAVO"), ParkCode("deva")], searchText: "a +&/#?é",
      sort: [.descending("parkCode"), .ascending("fullName")], start: 3,
      stateCodes: [StateCode("hi"), StateCode("CA")])
    #expect(
      Endpoint.parkFeesAndPasses(query: query).path
        == "/feespasses?limit=2&parkCode=HAVO,deva&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-parkCode,fullName&start=3&stateCode=hi,CA")
    #expect(Endpoint.collection(query) == Endpoint.parkFeesAndPasses(query: query))
  }

  @Test("Default fees and passes queries explicitly request fifty results at zero")
  func defaultFeesAndPassesQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.parkFeesAndPasses(query: ParkFeesAndPassesQuery()).path
        == "/feespasses?limit=50&start=0")
    #expect(
      try Endpoint.parkFeesAndPasses(query: ParkFeesAndPassesQuery(searchText: "")).path
        == "/feespasses?limit=50&q=&start=0")
  }

  @Test("Empty fees and passes code and sort arrays omit their parameters")
  func emptyFeesAndPassesCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ParkFeesAndPassesQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.parkFeesAndPasses(query: query).path == "/feespasses?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid fees and passes query pagination is rejected")
  func invalidFeesAndPassesQueryPaginationIsRejected() {
    #expect(throws: ParkFeesAndPassesQuery.ValidationError.invalidLimit) {
      try ParkFeesAndPassesQuery(limit: 0)
    }
    #expect(throws: ParkFeesAndPassesQuery.ValidationError.invalidLimit) {
      try ParkFeesAndPassesQuery(limit: -1)
    }
    #expect(throws: ParkFeesAndPassesQuery.ValidationError.invalidStart) {
      try ParkFeesAndPassesQuery(start: -1)
    }
  }

  @Test("Fees and passes sort fields are sent without validation or reordering")
  func feesAndPassesSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses isFeeFreePark with HTTP 400; the query still sends it as named.
    let query = try ParkFeesAndPassesQuery(
      limit: 1, sort: [.descending("isFeeFreePark"), .ascending("futureField")])
    #expect(
      Endpoint.parkFeesAndPasses(query: query).path
        == "/feespasses?limit=1&sort=-isFeeFreePark,futureField&start=0")
  }

  @Test("Fees and passes requests resolve as collections of the same query")
  func feesAndPassesRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkFeesAndPassesQuery(limit: 1, parkCodes: [ParkCode("havo")])
    let request = NPSDataRequest.parkFeesAndPasses(query: query)
    let _: NPSDataRequest<NPSCollection<ParkFeesAndPasses>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkFeesAndPasses(query: query)]).count == 1)
    #expect(request != .parkFeesAndPasses(query: try ParkFeesAndPassesQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkFeesAndPasses(query: query))
    #expect(resolution.query as? ParkFeesAndPassesQuery == query)
  }

  @Test("The recorded requests match the fees and passes query paths")
  func theRecordedRequestsMatchTheFeesAndPassesQueryPaths() throws {
    let search = try ParkFeesAndPassesQuery(
      limit: 2, parkCodes: [ParkCode("deva"), ParkCode("fova")], searchText: "annual",
      stateCodes: [StateCode("CA"), StateCode("WA")])
    #expect(
      Endpoint.parkFeesAndPasses(query: search).path
        == "/feespasses?limit=2&parkCode=deva,fova&q=annual&start=0&stateCode=CA,WA")
    let page = try ParkFeesAndPassesQuery(
      limit: 1, parkCodes: [ParkCode("hale"), ParkCode("havo")],
      sort: [.descending("parkCode")])
    #expect(
      Endpoint.parkFeesAndPasses(query: page).path
        == "/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=0")
    #expect(
      Endpoint.parkFeesAndPasses(query: page.starting(at: 1)).path
        == "/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=1")
    let empty = try ParkFeesAndPassesQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.parkFeesAndPasses(query: empty).path
        == "/feespasses?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A fees and passes query advances by the returned item count and keeps its filters")
  func aFeesAndPassesQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ParkFeesAndPassesQuery(
      limit: 1, parkCodes: [ParkCode("hale"), ParkCode("havo")], searchText: "pass",
      sort: [.descending("parkCode"), .ascending("fullName")], start: 0,
      stateCodes: [StateCode("HI")])
    let page = try JSONDecoder().decode(
      NPSCollection<ParkFeesAndPasses>.self, from: Fixture.parkFeesAndPassesPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.parkFeesAndPasses(query: next).path
        == "/feespasses?limit=1&parkCode=hale,havo&q=pass&sort=-parkCode,fullName&start=1"
        + "&stateCode=HI")
  }
}
