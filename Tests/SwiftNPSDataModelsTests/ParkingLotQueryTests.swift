import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Parking lot queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkingLotQueryTests {
  @Test("All documented parking lot parameters preserve caller values")
  func allDocumentedParkingLotParametersPreserveCallerValues() throws {
    let query = try ParkingLotQuery(
      limit: 2, parkCodes: [ParkCode("HAVO"), ParkCode("chsc")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("parkCode")], start: 3,
      stateCodes: [StateCode("hi"), StateCode("AR")])
    #expect(
      Endpoint.parkingLots(query: query).path
        == "/parkinglots?limit=2&parkCode=HAVO,chsc&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,parkCode&start=3&stateCode=hi,AR")
    #expect(Endpoint.collection(query) == Endpoint.parkingLots(query: query))
  }

  @Test("Default parking lot queries explicitly request fifty results at zero")
  func defaultParkingLotQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.parkingLots(query: ParkingLotQuery()).path == "/parkinglots?limit=50&start=0")
    #expect(
      try Endpoint.parkingLots(query: ParkingLotQuery(searchText: "")).path
        == "/parkinglots?limit=50&q=&start=0")
  }

  @Test("Empty parking lot code and sort arrays omit their parameters")
  func emptyParkingLotCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ParkingLotQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.parkingLots(query: query).path == "/parkinglots?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid parking lot query pagination is rejected")
  func invalidParkingLotQueryPaginationIsRejected() {
    #expect(throws: ParkingLotQuery.ValidationError.invalidLimit) {
      try ParkingLotQuery(limit: 0)
    }
    #expect(throws: ParkingLotQuery.ValidationError.invalidLimit) {
      try ParkingLotQuery(limit: -1)
    }
    #expect(throws: ParkingLotQuery.ValidationError.invalidStart) {
      try ParkingLotQuery(start: -1)
    }
  }

  @Test("Parking lot sort fields are sent without validation or reordering")
  func parkingLotSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses title with HTTP 400; the query still sends it as named.
    let query = try ParkingLotQuery(
      limit: 1, sort: [.descending("title"), .ascending("futureField")])
    #expect(
      Endpoint.parkingLots(query: query).path
        == "/parkinglots?limit=1&sort=-title,futureField&start=0")
  }

  @Test("Parking lot requests resolve as collections of the same query")
  func parkingLotRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkingLotQuery(limit: 1, parkCodes: [ParkCode("chsc")])
    let request = NPSDataRequest.parkingLots(query: query)
    let _: NPSDataRequest<NPSCollection<ParkingLot>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkingLots(query: query)]).count == 1)
    #expect(request != .parkingLots(query: try ParkingLotQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkingLots(query: query))
    #expect(resolution.query as? ParkingLotQuery == query)
  }

  @Test("The recorded requests match the parking lot query paths")
  func theRecordedRequestsMatchTheParkingLotQueryPaths() throws {
    let search = try ParkingLotQuery(
      limit: 2, parkCodes: [ParkCode("havo")], searchText: "overlook",
      sort: [.ascending("name")], stateCodes: [StateCode("HI")])
    #expect(
      Endpoint.parkingLots(query: search).path
        == "/parkinglots?limit=2&parkCode=havo&q=overlook&sort=name&start=0&stateCode=HI")
    let page = try ParkingLotQuery(
      limit: 1, parkCodes: [ParkCode("chsc")], sort: [.descending("name")])
    #expect(
      Endpoint.parkingLots(query: page).path
        == "/parkinglots?limit=1&parkCode=chsc&sort=-name&start=0")
    #expect(
      Endpoint.parkingLots(query: page.starting(at: 1)).path
        == "/parkinglots?limit=1&parkCode=chsc&sort=-name&start=1")
    let empty = try ParkingLotQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.parkingLots(query: empty).path == "/parkinglots?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A parking lot query advances by the returned item count and keeps its filters")
  func aParkingLotQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ParkingLotQuery(
      limit: 1, parkCodes: [ParkCode("chsc"), ParkCode("havo")], searchText: "parking",
      sort: [.descending("name"), .ascending("parkCode")], start: 0,
      stateCodes: [StateCode("AR"), StateCode("HI")])
    let page = try JSONDecoder().decode(
      NPSCollection<ParkingLot>.self, from: Fixture.parkingLotsPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.parkingLots(query: next).path
        == "/parkinglots?limit=1&parkCode=chsc,havo&q=parking&sort=-name,parkCode&start=1"
        + "&stateCode=AR,HI")
  }
}
