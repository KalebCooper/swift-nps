import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("News releases queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NewsReleaseQueryTests {
  @Test("All documented news release parameters preserve caller values")
  func allDocumentedNewsReleaseParametersPreserveCallerValues() throws {
    let query = try NewsReleaseQuery(
      limit: 2, parkCodes: [ParkCode("YELL"), ParkCode("anac")], searchText: "a +&/#?é",
      sort: [.descending("releaseDate"), .ascending("title")], start: 3,
      stateCodes: [StateCode("dc"), StateCode("WY")])
    #expect(
      Endpoint.newsReleases(query: query).path
        == "/newsreleases?limit=2&parkCode=YELL,anac&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-releaseDate,title&start=3&stateCode=dc,WY")
    #expect(Endpoint.collection(query) == Endpoint.newsReleases(query: query))
  }

  @Test("Default news release queries explicitly request fifty results at zero")
  func defaultNewsReleaseQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.newsReleases(query: NewsReleaseQuery()).path
        == "/newsreleases?limit=50&start=0")
    #expect(
      try Endpoint.newsReleases(query: NewsReleaseQuery(searchText: "")).path
        == "/newsreleases?limit=50&q=&start=0")
  }

  @Test("Empty code and sort arrays omit their parameters")
  func emptyCodeAndSortArraysOmitTheirParameters() throws {
    let query = try NewsReleaseQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.newsReleases(query: query).path == "/newsreleases?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid news release query pagination is rejected")
  func invalidNewsReleaseQueryPaginationIsRejected() {
    #expect(throws: NewsReleaseQuery.ValidationError.invalidLimit) {
      try NewsReleaseQuery(limit: 0)
    }
    #expect(throws: NewsReleaseQuery.ValidationError.invalidLimit) {
      try NewsReleaseQuery(limit: -1)
    }
    #expect(throws: NewsReleaseQuery.ValidationError.invalidStart) {
      try NewsReleaseQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try NewsReleaseQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.newsReleases(query: query).path
        == "/newsreleases?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("News release requests resolve as collections of the same query")
  func newsReleaseRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try NewsReleaseQuery(limit: 1, parkCodes: [ParkCode("yell")])
    let request = NPSDataRequest.newsReleases(query: query)
    let _: NPSDataRequest<NPSCollection<NewsRelease>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .newsReleases(query: query)]).count == 1)
    #expect(request != .newsReleases(query: try NewsReleaseQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.newsReleases(query: query))
    #expect(resolution.query as? NewsReleaseQuery == query)
  }

  @Test("The recorded requests match the news release query paths")
  func theRecordedRequestsMatchTheNewsReleaseQueryPaths() throws {
    let search = try NewsReleaseQuery(
      limit: 2, parkCodes: [ParkCode("anac")], searchText: "advisory", sort: [.ascending("title")],
      stateCodes: [StateCode("DC")])
    #expect(
      Endpoint.newsReleases(query: search).path
        == "/newsreleases?limit=2&parkCode=anac&q=advisory&sort=title&start=0&stateCode=DC")
    let page = try NewsReleaseQuery(
      limit: 1, parkCodes: [ParkCode("yell")], sort: [.descending("releaseDate")])
    #expect(
      Endpoint.newsReleases(query: page).path
        == "/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=0")
    #expect(
      Endpoint.newsReleases(query: page.starting(at: 1)).path
        == "/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=1")
    let empty = try NewsReleaseQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.newsReleases(query: empty).path == "/newsreleases?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A news release query advances by the returned item count and keeps its filters")
  func aNewsReleaseQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try NewsReleaseQuery(
      limit: 1, parkCodes: [ParkCode("yell")], searchText: "bison",
      sort: [.descending("releaseDate")], stateCodes: [StateCode("WY")])
    let page = try JSONDecoder().decode(
      NPSCollection<NewsRelease>.self, from: Fixture.newsReleasesPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.newsReleases(query: next).path
        == "/newsreleases?limit=1&parkCode=yell&q=bison&sort=-releaseDate&start=1&stateCode=WY")
  }
}
