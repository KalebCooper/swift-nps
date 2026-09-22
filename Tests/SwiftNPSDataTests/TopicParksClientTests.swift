import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Topic parks client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TopicParksClientTests {
  private static let firstPath =
    "/api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,"
    + "7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=0"
  private static let lastPath =
    "/api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,"
    + "7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=1&parkCode=mamc&sort=-name&start=1"

  @Test(
    "An empty topic parks page ends iteration without another request",
    arguments: [false, true])
  func anEmptyTopicParksPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.topicParksEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try TopicParksQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var topics: [TopicParks] = []
      for try await topic in client.topicParks(query: query) { topics.append(topic) }
      #expect(topics.isEmpty)
    } else {
      var pages: [NPSCollection<TopicParks>] = []
      for try await page in client.topicParkPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/topics/parks?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Topic parks item iteration fetches the next page only when needed")
  func topicParksItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.topicParksPageFirst.data())),
        .success(.ok(json: Fixture.topicParksPageLast.data())),
      ])
    let sequence = try makeClient(transport).topicParks(query: makeQuery())
    let _: NPSItemSequence<TopicParks> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "Women's History")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "African American Heritage")
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
  }

  @Test("Topic parks pages advance lazily through the recorded pages")
  func topicParksPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.topicParksPageFirst.data()
    let last = try Fixture.topicParksPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).topicParkPages(query: makeQuery())
    let _: NPSPageSequence<TopicParks> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<TopicParks>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<TopicParks>.self, from: last)))
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable topic parks requests return the same page as their endpoint")
  func reusableTopicParksRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.topicParksSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try TopicParksQuery(
      identifiers: [
        NPSIdentifier("28AEAE85-9DDA-45B6-981B-1CFCDCC61E14"),
        NPSIdentifier("7DA81DAB-5045-4953-9C20-36590AD9FA95"),
      ], limit: 2, parkCodes: [ParkCode("acad"), ParkCode("mamc")], searchText: "history",
      sort: [.descending("name")])
    let reusable = try await client.value(for: .topicParks(query: query))
    let endpoint = try await client.send(.topicParks(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.name) == ["Women's History"])
    let path =
      "/api/v1/topics/parks?id=28AEAE85-9DDA-45B6-981B-1CFCDCC61E14,"
      + "7DA81DAB-5045-4953-9C20-36590AD9FA95&limit=2&parkCode=acad,mamc&q=history&sort=-name"
      + "&start=0"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> TopicParksQuery {
    try TopicParksQuery(
      identifiers: [
        NPSIdentifier("28AEAE85-9DDA-45B6-981B-1CFCDCC61E14"),
        NPSIdentifier("7DA81DAB-5045-4953-9C20-36590AD9FA95"),
      ], limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
  }
}
