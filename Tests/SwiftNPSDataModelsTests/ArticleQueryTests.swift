import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Articles queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ArticleQueryTests {
  @Test("All documented article parameters preserve caller values")
  func allDocumentedArticleParametersPreserveCallerValues() throws {
    let query = try ArticleQuery(
      limit: 2, parkCodes: [ParkCode("ARCH"), ParkCode("yell")], searchText: "a +&/#?é", start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.articles(query: query).path
        == "/articles?limit=2&parkCode=ARCH,yell&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&start=3&stateCode=me,WY")
    #expect(Endpoint.collection(query) == Endpoint.articles(query: query))
  }

  @Test("Default article queries explicitly request fifty results at zero")
  func defaultArticleQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(try Endpoint.articles(query: ArticleQuery()).path == "/articles?limit=50&start=0")
    #expect(
      try Endpoint.articles(query: ArticleQuery(searchText: "")).path
        == "/articles?limit=50&q=&start=0")
  }

  @Test("Empty code arrays omit their parameters")
  func emptyCodeArraysOmitTheirParameters() throws {
    let query = try ArticleQuery(limit: 1, parkCodes: [], stateCodes: [])
    #expect(Endpoint.articles(query: query).path == "/articles?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid article query pagination is rejected")
  func invalidArticleQueryPaginationIsRejected() {
    #expect(throws: ArticleQuery.ValidationError.invalidLimit) { try ArticleQuery(limit: 0) }
    #expect(throws: ArticleQuery.ValidationError.invalidLimit) { try ArticleQuery(limit: -1) }
    #expect(throws: ArticleQuery.ValidationError.invalidStart) { try ArticleQuery(start: -1) }
  }

  @Test("Article queries send no sort parameter")
  func articleQueriesSendNoSortParameter() throws {
    // The live endpoint answers HTTP 400 for every sort value, so the query offers none.
    let query = try ArticleQuery(
      limit: 2, parkCodes: [ParkCode("arch")], searchText: "geology", start: 1,
      stateCodes: [StateCode("UT")])
    #expect(query.queryItems.map(\.name) == ["limit", "parkCode", "q", "start", "stateCode"])
    #expect(Endpoint.articles(query: query).path.contains("sort") == false)
  }

  @Test("Article requests resolve as collections of the same query")
  func articleRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ArticleQuery(limit: 1, parkCodes: [ParkCode("arch")])
    let request = NPSDataRequest.articles(query: query)
    let _: NPSDataRequest<NPSCollection<Article>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .articles(query: query)]).count == 1)
    #expect(request != .articles(query: try ArticleQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.articles(query: query))
    #expect(resolution.query as? ArticleQuery == query)
  }

  @Test("The recorded requests match the article query paths")
  func theRecordedRequestsMatchTheArticleQueryPaths() throws {
    let search = try ArticleQuery(
      limit: 2, parkCodes: [ParkCode("gumo")], searchText: "Salt", stateCodes: [StateCode("TX")])
    #expect(
      Endpoint.articles(query: search).path
        == "/articles?limit=2&parkCode=gumo&q=Salt&start=0&stateCode=TX")
    let page = try ArticleQuery(limit: 1, parkCodes: [ParkCode("arch")])
    #expect(Endpoint.articles(query: page).path == "/articles?limit=1&parkCode=arch&start=0")
    #expect(
      Endpoint.articles(query: page.starting(at: 1)).path
        == "/articles?limit=1&parkCode=arch&start=1")
    let empty = try ArticleQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(Endpoint.articles(query: empty).path == "/articles?limit=1&parkCode=zzzz&start=0")
  }

  @Test("An article query advances by the returned item count and keeps its filters")
  func anArticleQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ArticleQuery(
      limit: 2, parkCodes: [ParkCode("gumo")], searchText: "Salt", stateCodes: [StateCode("TX")])
    let page = try JSONDecoder().decode(
      NPSCollection<Article>.self, from: Fixture.articlesSearch.data())
    let next = try #require(try query.next(after: page))
    #expect(next == query.starting(at: 2))
    #expect(
      Endpoint.articles(query: next).path
        == "/articles?limit=2&parkCode=gumo&q=Salt&start=2&stateCode=TX")
  }
}
