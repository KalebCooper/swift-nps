import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Topics client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkTopicClientTests {
  private static let firstPath =
    "/api/v1/topics?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,"
    + "7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=0"
  private static let lastPath =
    "/api/v1/topics?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,"
    + "7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=1"

  @Test(
    "An empty topics page ends iteration without another request",
    arguments: [false, true])
  func anEmptyTopicsPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.topicsEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try ParkTopicQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var topics: [ParkTopic] = []
      for try await topic in client.parkTopics(query: query) { topics.append(topic) }
      #expect(topics.isEmpty)
    } else {
      var pages: [NPSCollection<ParkTopic>] = []
      for try await page in client.parkTopicPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/topics?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Topics item iteration fetches the next page only when needed")
  func topicsItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.topicsPageFirst.data())),
        .success(.ok(json: Fixture.topicsPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkTopics(query: makeQuery())
    let _: NPSItemSequence<ParkTopic> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "Women's History")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "African American Heritage")
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
  }

  @Test("Topics pages advance lazily through the recorded pages")
  func topicsPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.topicsPageFirst.data()
    let last = try Fixture.topicsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkTopicPages(query: makeQuery())
    let _: NPSPageSequence<ParkTopic> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<ParkTopic>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ParkTopic>.self, from: last)))
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable topics requests return the same page as their endpoint")
  func reusableTopicsRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.topicsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkTopicQuery(
      limit: 2, parkCodes: [ParkCode("acad"), ParkCode("mamc")], searchText: "history",
      sort: [.descending("name")])
    let reusable = try await client.value(for: .parkTopics(query: query))
    let endpoint = try await client.send(.parkTopics(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.name) == ["Women's History"])
    let path = "/api/v1/topics?limit=2&parkCode=acad,mamc&q=history&sort=-name&start=0"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkTopicQuery {
    try ParkTopicQuery(
      identifiers: [
        NPSIdentifier("28AEAE85-9DDA-45B6-981B-1CFCDCC61E14"),
        NPSIdentifier("7DA81DAB-5045-4953-9C20-36590AD9FA95"),
      ], limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
  }
}
