import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Places queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PlaceQueryTests {
  @Test("All documented place parameters preserve caller values")
  func allDocumentedPlaceParametersPreserveCallerValues() throws {
    let query = try PlaceQuery(
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é", start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.places(query: query).path
        == "/places?limit=2&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&start=3&stateCode=me,WY")
    #expect(Endpoint.collection(query) == Endpoint.places(query: query))
  }

  @Test("Default place queries explicitly request fifty results at zero")
  func defaultPlaceQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.places(query: PlaceQuery()).path == "/places?limit=50&start=0")
    #expect(
      try Endpoint.places(query: PlaceQuery(searchText: "")).path == "/places?limit=50&q=&start=0")
  }

  @Test("Empty code arrays omit their parameters")
  func emptyCodeArraysOmitTheirParameters() throws {
    let query = try PlaceQuery(limit: 1, parkCodes: [], stateCodes: [])
    #expect(Endpoint.places(query: query).path == "/places?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid place query pagination is rejected")
  func invalidPlaceQueryPaginationIsRejected() {
    #expect(throws: PlaceQuery.ValidationError.invalidLimit) { try PlaceQuery(limit: 0) }
    #expect(throws: PlaceQuery.ValidationError.invalidLimit) { try PlaceQuery(limit: -1) }
    #expect(throws: PlaceQuery.ValidationError.invalidStart) { try PlaceQuery(start: -1) }
  }

  @Test("Place queries send no sort parameter")
  func placeQueriesSendNoSortParameter() throws {
    // The live endpoint answers HTTP 400 for every sort value, so the query offers none.
    let query = try PlaceQuery(
      limit: 2, parkCodes: [ParkCode("acad")], searchText: "trail", start: 1,
      stateCodes: [StateCode("ME")])
    #expect(query.queryItems.map(\.name) == ["limit", "parkCode", "q", "start", "stateCode"])
    #expect(Endpoint.places(query: query).path.contains("sort") == false)
  }

  @Test("Place requests resolve as collections of the same query")
  func placeRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try PlaceQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let request = NPSDataRequest.places(query: query)
    let _: NPSDataRequest<NPSCollection<Place>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .places(query: query)]).count == 1)
    #expect(request != .places(query: try PlaceQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.places(query: query))
    #expect(resolution.query as? PlaceQuery == query)
  }

  @Test("The recorded requests match the place query paths")
  func theRecordedRequestsMatchThePlaceQueryPaths() throws {
    let search = try PlaceQuery(
      limit: 2, searchText: "Redoubt", stateCodes: [StateCode("FL")])
    #expect(
      Endpoint.places(query: search).path == "/places?limit=2&q=Redoubt&start=0&stateCode=FL")
    let page = try PlaceQuery(limit: 1, parkCodes: [ParkCode("acad")])
    #expect(Endpoint.places(query: page).path == "/places?limit=1&parkCode=acad&start=0")
    #expect(
      Endpoint.places(query: page.starting(at: 1)).path
        == "/places?limit=1&parkCode=acad&start=1")
  }
}
