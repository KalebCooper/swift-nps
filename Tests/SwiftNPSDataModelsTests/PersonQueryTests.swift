import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("People queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PersonQueryTests {
  @Test("All documented people parameters preserve caller values")
  func allDocumentedPeopleParametersPreserveCallerValues() throws {
    let query = try PersonQuery(
      limit: 2, parkCodes: [ParkCode("ARCH"), ParkCode("yell")], searchText: "a +&/#?é", start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.people(query: query).path
        == "/people?limit=2&parkCode=ARCH,yell&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&start=3&stateCode=me,WY")
    #expect(Endpoint.collection(query) == Endpoint.people(query: query))
  }

  @Test("Default people queries explicitly request fifty results at zero")
  func defaultPeopleQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.people(query: PersonQuery()).path == "/people?limit=50&start=0")
    #expect(
      try Endpoint.people(query: PersonQuery(searchText: "")).path
        == "/people?limit=50&q=&start=0")
  }

  @Test("Empty code arrays omit their parameters")
  func emptyCodeArraysOmitTheirParameters() throws {
    let query = try PersonQuery(limit: 1, parkCodes: [], stateCodes: [])
    #expect(Endpoint.people(query: query).path == "/people?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid people query pagination is rejected")
  func invalidPeopleQueryPaginationIsRejected() {
    #expect(throws: PersonQuery.ValidationError.invalidLimit) { try PersonQuery(limit: 0) }
    #expect(throws: PersonQuery.ValidationError.invalidLimit) { try PersonQuery(limit: -1) }
    #expect(throws: PersonQuery.ValidationError.invalidStart) { try PersonQuery(start: -1) }
  }

  @Test("People queries send no sort parameter")
  func peopleQueriesSendNoSortParameter() throws {
    // The live endpoint answers HTTP 400 for every sort value, so the query offers none.
    let query = try PersonQuery(
      limit: 2, parkCodes: [ParkCode("yell")], searchText: "Moran", start: 1,
      stateCodes: [StateCode("WY")])
    #expect(query.queryItems.map(\.name) == ["limit", "parkCode", "q", "start", "stateCode"])
    #expect(Endpoint.people(query: query).path.contains("sort") == false)
  }

  @Test("People requests resolve as collections of the same query")
  func peopleRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try PersonQuery(limit: 1, parkCodes: [ParkCode("yell")])
    let request = NPSDataRequest.people(query: query)
    let _: NPSDataRequest<NPSCollection<Person>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .people(query: query)]).count == 1)
    #expect(request != .people(query: try PersonQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.people(query: query))
    #expect(resolution.query as? PersonQuery == query)
  }

  @Test("The recorded requests match the people query paths")
  func theRecordedRequestsMatchThePeopleQueryPaths() throws {
    let search = try PersonQuery(
      limit: 2, parkCodes: [ParkCode("frla")], searchText: "Olmsted", stateCodes: [StateCode("MA")])
    #expect(
      Endpoint.people(query: search).path
        == "/people?limit=2&parkCode=frla&q=Olmsted&start=0&stateCode=MA")
    let page = try PersonQuery(limit: 1, parkCodes: [ParkCode("yell")])
    #expect(Endpoint.people(query: page).path == "/people?limit=1&parkCode=yell&start=0")
    #expect(
      Endpoint.people(query: page.starting(at: 1)).path
        == "/people?limit=1&parkCode=yell&start=1")
    let empty = try PersonQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(Endpoint.people(query: empty).path == "/people?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A people query advances by the returned item count and keeps its filters")
  func aPeopleQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try PersonQuery(
      limit: 2, parkCodes: [ParkCode("frla")], searchText: "Olmsted", stateCodes: [StateCode("MA")])
    let page = try JSONDecoder().decode(
      NPSCollection<Person>.self, from: Fixture.peopleSearch.data())
    let next = try #require(try query.next(after: page))
    #expect(next == query.starting(at: 2))
    #expect(
      Endpoint.people(query: next).path
        == "/people?limit=2&parkCode=frla&q=Olmsted&start=2&stateCode=MA")
  }
}
