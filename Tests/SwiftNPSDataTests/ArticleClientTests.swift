import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Articles client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ArticleClientTests {
  @Test("An empty article page ends iteration without another request", arguments: [false, true])
  func anEmptyArticlePageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.articlesEmpty.data()))])
    let client = try makeClient(transport)
    let query = try ArticleQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var articles: [Article] = []
      for try await article in client.articles(query: query) { articles.append(article) }
      #expect(articles.isEmpty)
    } else {
      var pages: [NPSCollection<Article>] = []
      for try await page in client.articlePages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == ["/api/v1/articles?limit=1&parkCode=zzzz&start=0"])
  }

  @Test("Article item iteration fetches the next page only when needed")
  func articleItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.articlesPageFirst.data())),
        .success(.ok(json: Fixture.articlesPageLast.data())),
      ])
    let sequence = try makeClient(transport).articles(query: makeQuery())
    let _: NPSItemSequence<Article> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "DCEC38A7-B376-40DC-92E9-C46D92A272E9")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "B37992BF-7CC1-4350-8235-901C00C1A097")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/articles?limit=1&parkCode=arch&start=0",
        "/api/v1/articles?limit=1&parkCode=arch&start=1",
      ])
  }

  @Test("Article pages advance lazily through the recorded pages")
  func articlePagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.articlesPageFirst.data()
    let last = try Fixture.articlesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).articlePages(query: makeQuery())
    let _: NPSPageSequence<Article> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<Article>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<Article>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/articles?limit=1&parkCode=arch&start=0",
        "/api/v1/articles?limit=1&parkCode=arch&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable article requests return the same page as their endpoint")
  func reusableArticleRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.articlesSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ArticleQuery(
      limit: 2, parkCodes: [ParkCode("gumo")], searchText: "Salt", stateCodes: [StateCode("TX")])
    let reusable = try await client.value(for: .articles(query: query))
    let endpoint = try await client.send(.articles(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "54580218-6515-4AEB-9730-29E035DF23CF", "FA8F6462-6F58-4993-8A35-ABEE0EF32F26",
      ])
    let path = "/api/v1/articles?limit=2&parkCode=gumo&q=Salt&start=0&stateCode=TX"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ArticleQuery {
    try ArticleQuery(limit: 1, parkCodes: [ParkCode("arch")])
  }
}
