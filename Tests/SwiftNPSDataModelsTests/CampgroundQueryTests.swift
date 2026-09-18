import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Campgrounds queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct CampgroundQueryTests {
  @Test("All documented campground parameters preserve caller values")
  func allDocumentedCampgroundParametersPreserveCallerValues() throws {
    let query = try CampgroundQuery(
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("parkCode")], start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.campgrounds(query: query).path
        == "/campgrounds?limit=2&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,parkCode&start=3&stateCode=me,WY")
    #expect(Endpoint.collection(query) == Endpoint.campgrounds(query: query))
  }

  @Test("Campground requests resolve as collections of the same query")
  func campgroundRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try CampgroundQuery(limit: 1, parkCodes: [ParkCode("acad")])
    let request = NPSDataRequest.campgrounds(query: query)
    let _: NPSDataRequest<NPSCollection<Campground>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .campgrounds(query: query)]).count == 1)
    #expect(request != .campgrounds(query: try CampgroundQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.campgrounds(query: query))
    #expect(resolution.query as? CampgroundQuery == query)
  }

  @Test("Default campground queries explicitly request fifty results at zero")
  func defaultCampgroundQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.campgrounds(query: CampgroundQuery()).path
        == "/campgrounds?limit=50&start=0")
    #expect(
      try Endpoint.campgrounds(query: CampgroundQuery(searchText: "")).path
        == "/campgrounds?limit=50&q=&start=0")
  }

  @Test("Empty code and sort arrays omit their parameters")
  func emptyCodeAndSortArraysOmitTheirParameters() throws {
    let query = try CampgroundQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.campgrounds(query: query).path == "/campgrounds?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid campground query pagination is rejected")
  func invalidCampgroundQueryPaginationIsRejected() {
    #expect(throws: CampgroundQuery.ValidationError.invalidLimit) {
      try CampgroundQuery(limit: 0)
    }
    #expect(throws: CampgroundQuery.ValidationError.invalidLimit) {
      try CampgroundQuery(limit: -1)
    }
    #expect(throws: CampgroundQuery.ValidationError.invalidStart) {
      try CampgroundQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    let query = try CampgroundQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.campgrounds(query: query).path
        == "/campgrounds?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("The recorded requests match the campground query paths")
  func theRecordedRequestsMatchTheCampgroundQueryPaths() throws {
    let search = try CampgroundQuery(
      limit: 2, searchText: "lake", sort: [.ascending("name")],
      stateCodes: [StateCode("WY")])
    #expect(
      Endpoint.campgrounds(query: search).path
        == "/campgrounds?limit=2&q=lake&sort=name&start=0&stateCode=WY")
    let page = try CampgroundQuery(
      limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
    #expect(
      Endpoint.campgrounds(query: page).path
        == "/campgrounds?limit=1&parkCode=acad&sort=name&start=0")
    #expect(
      Endpoint.campgrounds(query: page.starting(at: 1)).path
        == "/campgrounds?limit=1&parkCode=acad&sort=name&start=1")
  }
}
