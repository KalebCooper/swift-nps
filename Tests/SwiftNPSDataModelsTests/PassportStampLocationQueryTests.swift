import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Passport stamp location queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PassportStampLocationQueryTests {
  @Test("All documented passport stamp location parameters preserve caller values")
  func allDocumentedPassportStampLocationParametersPreserveCallerValues() throws {
    let query = try PassportStampLocationQuery(
      identifiers: [NPSIdentifier("B2"), NPSIdentifier("A1")], limit: 2,
      parkCodes: [ParkCode("YELL"), ParkCode("grte")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("futureField")], start: 3,
      stateCodes: [StateCode("wy"), StateCode("MT")])
    #expect(
      Endpoint.passportStampLocations(query: query).path
        == "/passportstamplocations?id=B2,A1&limit=2&parkCode=YELL,grte"
        + "&q=a%20%2B%26%2F%23%3F%C3%A9&sort=-name,futureField&start=3&stateCode=wy,MT")
    #expect(Endpoint.collection(query) == Endpoint.passportStampLocations(query: query))
  }

  @Test("Default passport stamp location queries explicitly request fifty results at zero")
  func defaultPassportStampLocationQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.passportStampLocations(query: PassportStampLocationQuery()).path
        == "/passportstamplocations?limit=50&start=0")
    #expect(
      try Endpoint.passportStampLocations(query: PassportStampLocationQuery(searchText: "")).path
        == "/passportstamplocations?limit=50&q=&start=0")
  }

  @Test("Empty passport stamp location identifier, code, and sort arrays omit their parameters")
  func emptyPassportStampLocationIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try PassportStampLocationQuery(
      identifiers: [], limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(
      Endpoint.passportStampLocations(query: query).path
        == "/passportstamplocations?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid passport stamp location query pagination is rejected")
  func invalidPassportStampLocationQueryPaginationIsRejected() {
    #expect(throws: PassportStampLocationQuery.ValidationError.invalidLimit) {
      try PassportStampLocationQuery(limit: 0)
    }
    #expect(throws: PassportStampLocationQuery.ValidationError.invalidLimit) {
      try PassportStampLocationQuery(limit: -1)
    }
    #expect(throws: PassportStampLocationQuery.ValidationError.invalidStart) {
      try PassportStampLocationQuery(start: -1)
    }
  }

  @Test("Passport stamp location sort fields are sent without validation or reordering")
  func passportStampLocationSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses label with HTTP 400; the query still sends it as named.
    let query = try PassportStampLocationQuery(
      limit: 1, sort: [.descending("label"), .ascending("name")])
    #expect(
      Endpoint.passportStampLocations(query: query).path
        == "/passportstamplocations?limit=1&sort=-label,name&start=0")
  }

  @Test("Passport stamp location requests resolve as collections of the same query")
  func passportStampLocationRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try PassportStampLocationQuery(limit: 1, parkCodes: [ParkCode("cato")])
    let request = NPSDataRequest.passportStampLocations(query: query)
    let _: NPSDataRequest<NPSCollection<PassportStampLocation>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .passportStampLocations(query: query)]).count == 1)
    #expect(request != .passportStampLocations(query: try PassportStampLocationQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.passportStampLocations(query: query))
    #expect(resolution.query as? PassportStampLocationQuery == query)
  }

  @Test("The recorded requests match the passport stamp location query paths")
  func theRecordedRequestsMatchThePassportStampLocationQueryPaths() throws {
    let search = try PassportStampLocationQuery(
      limit: 3, parkCodes: [ParkCode("cagr"), ParkCode("mamc")], searchText: "national",
      sort: [.descending("name")], stateCodes: [StateCode("AZ"), StateCode("DC")])
    #expect(
      Endpoint.passportStampLocations(query: search).path
        == "/passportstamplocations?limit=3&parkCode=cagr,mamc&q=national&sort=-name&start=0"
        + "&stateCode=AZ,DC")
    let page = try PassportStampLocationQuery(
      identifiers: [
        NPSIdentifier("74C8535F-4F9C-411F-B3F1-AE14E8C14AA2"),
        NPSIdentifier("9EE76DDC-80AB-4283-BCE9-F85952ED03E1"),
      ], limit: 1, parkCodes: [ParkCode("cato")], sort: [.descending("name")])
    let ids = "74C8535F-4F9C-411F-B3F1-AE14E8C14AA2,9EE76DDC-80AB-4283-BCE9-F85952ED03E1"
    #expect(
      Endpoint.passportStampLocations(query: page).path
        == "/passportstamplocations?id=\(ids)&limit=1&parkCode=cato&sort=-name&start=0")
    #expect(
      Endpoint.passportStampLocations(query: page.starting(at: 1)).path
        == "/passportstamplocations?id=\(ids)&limit=1&parkCode=cato&sort=-name&start=1")
    let empty = try PassportStampLocationQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.passportStampLocations(query: empty).path
        == "/passportstamplocations?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A passport stamp location query advances by the returned item count and keeps its filters")
  func aPassportStampLocationQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try PassportStampLocationQuery(
      identifiers: [NPSIdentifier("A1")], limit: 1, parkCodes: [ParkCode("cato")],
      searchText: "center", sort: [.descending("name")], start: 0,
      stateCodes: [StateCode("MD")])
    let page = try JSONDecoder().decode(
      NPSCollection<PassportStampLocation>.self,
      from: Fixture.passportStampLocationsPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.passportStampLocations(query: next).path
        == "/passportstamplocations?id=A1&limit=1&parkCode=cato&q=center&sort=-name&start=1"
        + "&stateCode=MD")
  }
}
