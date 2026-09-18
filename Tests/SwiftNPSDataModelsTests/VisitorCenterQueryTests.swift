import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Visitor centers queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct VisitorCenterQueryTests {
  @Test("All documented visitor center parameters preserve caller values")
  func allDocumentedVisitorCenterParametersPreserveCallerValues() throws {
    let query = try VisitorCenterQuery(
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("parkCode")], start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.visitorCenters(query: query).path
        == "/visitorcenters?limit=2&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,parkCode&start=3&stateCode=me,WY")
    #expect(Endpoint.collection(query) == Endpoint.visitorCenters(query: query))
  }

  @Test("Default visitor center queries explicitly request fifty results at zero")
  func defaultVisitorCenterQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.visitorCenters(query: VisitorCenterQuery()).path
        == "/visitorcenters?limit=50&start=0")
    #expect(
      try Endpoint.visitorCenters(query: VisitorCenterQuery(searchText: "")).path
        == "/visitorcenters?limit=50&q=&start=0")
  }

  @Test("Empty code and sort arrays omit their parameters")
  func emptyCodeAndSortArraysOmitTheirParameters() throws {
    let query = try VisitorCenterQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.visitorCenters(query: query).path == "/visitorcenters?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid visitor center query pagination is rejected")
  func invalidVisitorCenterQueryPaginationIsRejected() {
    #expect(throws: VisitorCenterQuery.ValidationError.invalidLimit) {
      try VisitorCenterQuery(limit: 0)
    }
    #expect(throws: VisitorCenterQuery.ValidationError.invalidLimit) {
      try VisitorCenterQuery(limit: -1)
    }
    #expect(throws: VisitorCenterQuery.ValidationError.invalidStart) {
      try VisitorCenterQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    let query = try VisitorCenterQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.visitorCenters(query: query).path
        == "/visitorcenters?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("The recorded requests match the visitor center query paths")
  func theRecordedRequestsMatchTheVisitorCenterQueryPaths() throws {
    let search = try VisitorCenterQuery(
      limit: 2, searchText: "museum", sort: [.ascending("name")],
      stateCodes: [StateCode("ME"), StateCode("MA")])
    #expect(
      Endpoint.visitorCenters(query: search).path
        == "/visitorcenters?limit=2&q=museum&sort=name&start=0&stateCode=ME,MA")
    let page = try VisitorCenterQuery(
      limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
    #expect(
      Endpoint.visitorCenters(query: page).path
        == "/visitorcenters?limit=1&parkCode=acad&sort=name&start=0")
    #expect(
      Endpoint.visitorCenters(query: page.starting(at: 1)).path
        == "/visitorcenters?limit=1&parkCode=acad&sort=name&start=1")
  }

  @Test("Visitor center requests resolve as collections of the same query")
  func visitorCenterRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try VisitorCenterQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let request = NPSDataRequest.visitorCenters(query: query)
    let _: NPSDataRequest<NPSCollection<VisitorCenter>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .visitorCenters(query: query)]).count == 1)
    #expect(request != .visitorCenters(query: try VisitorCenterQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.visitorCenters(query: query))
    #expect(resolution.query as? VisitorCenterQuery == query)
  }
}
