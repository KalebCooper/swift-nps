import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Alerts queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkAlertQueryTests {
  @Test("Alert requests resolve as collections of the same query")
  func alertRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkAlertQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let request = NPSDataRequest.parkAlerts(query: query)
    let _: NPSDataRequest<NPSCollection<ParkAlert>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkAlerts(query: query)]).count == 1)
    #expect(request != .parkAlerts(query: try ParkAlertQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkAlerts(query: query))
    #expect(resolution.query as? ParkAlertQuery == query)
  }

  @Test("All documented alert parameters preserve caller values")
  func allDocumentedAlertParametersPreserveCallerValues() throws {
    let query = try ParkAlertQuery(
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é", start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.parkAlerts(query: query).path
        == "/alerts?limit=2&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9&start=3&stateCode=me,WY"
    )
    #expect(Endpoint.collection(query) == Endpoint.parkAlerts(query: query))
  }

  @Test("Default alert queries explicitly request fifty results at zero")
  func defaultAlertQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.parkAlerts(query: ParkAlertQuery()).path == "/alerts?limit=50&start=0")
    #expect(
      try Endpoint.parkAlerts(query: ParkAlertQuery(searchText: "")).path
        == "/alerts?limit=50&q=&start=0")
  }

  @Test("Empty code arrays omit their parameters")
  func emptyCodeArraysOmitTheirParameters() throws {
    let query = try ParkAlertQuery(limit: 1, parkCodes: [], stateCodes: [])
    #expect(Endpoint.parkAlerts(query: query).path == "/alerts?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid alert query pagination is rejected")
  func invalidAlertQueryPaginationIsRejected() {
    #expect(throws: ParkAlertQuery.ValidationError.invalidLimit) { try ParkAlertQuery(limit: 0) }
    #expect(throws: ParkAlertQuery.ValidationError.invalidLimit) { try ParkAlertQuery(limit: -1) }
    #expect(throws: ParkAlertQuery.ValidationError.invalidStart) { try ParkAlertQuery(start: -1) }
  }

  @Test("The recorded search request matches the alert query path")
  func theRecordedSearchRequestMatchesTheAlertQueryPath() throws {
    let query = try ParkAlertQuery(limit: 2, parkCodes: [ParkCode("acad"), ParkCode("yell")])
    #expect(Endpoint.parkAlerts(query: query).path == "/alerts?limit=2&parkCode=acad,yell&start=0")
  }
}
