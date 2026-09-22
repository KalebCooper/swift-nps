import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("News releases client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NewsReleaseClientTests {
  @Test(
    "An empty news release page ends iteration without another request", arguments: [false, true])
  func anEmptyNewsReleasePageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(
      results: [.success(.ok(json: try Fixture.newsReleasesEmpty.data()))])
    let client = try makeClient(transport)
    let query = try NewsReleaseQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var releases: [NewsRelease] = []
      for try await release in client.newsReleases(query: query) { releases.append(release) }
      #expect(releases.isEmpty)
    } else {
      var pages: [NPSCollection<NewsRelease>] = []
      for try await page in client.newsReleasePages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/newsreleases?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("News release item iteration fetches the next page only when needed")
  func newsReleaseItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.newsReleasesPageFirst.data())),
        .success(.ok(json: Fixture.newsReleasesPageLast.data())),
      ])
    let sequence = try makeClient(transport).newsReleases(query: makeQuery())
    let _: NPSItemSequence<NewsRelease> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "1E2E3378-3BB5-469F-B1F5-90187DC513A5")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "5F507B4F-FFB9-4AA6-B608-712C4A3A1077")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=0",
        "/api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=1",
      ])
  }

  @Test("News release pages advance lazily through the recorded pages")
  func newsReleasePagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.newsReleasesPageFirst.data()
    let last = try Fixture.newsReleasesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).newsReleasePages(query: makeQuery())
    let _: NPSPageSequence<NewsRelease> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<NewsRelease>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<NewsRelease>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=0",
        "/api/v1/newsreleases?limit=1&parkCode=yell&sort=-releaseDate&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable news release requests return the same page as their endpoint")
  func reusableNewsReleaseRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.newsReleasesSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try NewsReleaseQuery(
      limit: 2, parkCodes: [ParkCode("anac")], searchText: "advisory", sort: [.ascending("title")],
      stateCodes: [StateCode("DC")])
    let reusable = try await client.value(for: .newsReleases(query: query))
    let endpoint = try await client.send(.newsReleases(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "A4CA6BB5-F553-4F4B-8A5E-7C974DAC4FE8", "590F673C-4C2A-4E5D-85CF-8B5EAE0847DF",
      ])
    let path =
      "/api/v1/newsreleases?limit=2&parkCode=anac&q=advisory&sort=title&start=0&stateCode=DC"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> NewsReleaseQuery {
    try NewsReleaseQuery(
      limit: 1, parkCodes: [ParkCode("yell")], sort: [.descending("releaseDate")])
  }
}
