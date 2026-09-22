import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park audio client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkAudioClientTests {
  @Test(
    "An empty park audio page ends iteration without another request", arguments: [false, true])
  func anEmptyParkAudioPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parkAudioEmpty.data()))])
    let client = try makeClient(transport)
    let query = try ParkAudioQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var recordings: [ParkAudio] = []
      for try await audio in client.parkAudio(query: query) { recordings.append(audio) }
      #expect(recordings.isEmpty)
    } else {
      var pages: [NPSCollection<ParkAudio>] = []
      for try await page in client.parkAudioPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/audio?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Park audio item iteration fetches the next page only when needed")
  func parkAudioItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parkAudioPageFirst.data())),
        .success(.ok(json: Fixture.parkAudioPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkAudio(query: makeQuery())
    let _: NPSItemSequence<ParkAudio> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "84F895EE-31C4-4D17-BB01-5AF0AADE3F30")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "F9283688-390A-4B61-B0AE-55CC15A03B36")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/audio?limit=1&parkCode=choh&start=0",
        "/api/v1/multimedia/audio?limit=1&parkCode=choh&start=1",
      ])
  }

  @Test("Park audio pages advance lazily through the recorded pages")
  func parkAudioPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.parkAudioPageFirst.data()
    let last = try Fixture.parkAudioPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkAudioPages(query: makeQuery())
    let _: NPSPageSequence<ParkAudio> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<ParkAudio>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ParkAudio>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/audio?limit=1&parkCode=choh&start=0",
        "/api/v1/multimedia/audio?limit=1&parkCode=choh&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable park audio requests return the same page as their endpoint")
  func reusableParkAudioRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.parkAudioSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkAudioQuery(
      limit: 2, parkCodes: [ParkCode("ever")], searchText: "alligator",
      sort: [.ascending("title")], stateCodes: [StateCode("FL")])
    let reusable = try await client.value(for: .parkAudio(query: query))
    let endpoint = try await client.send(.parkAudio(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "D9E5E229-63EB-4CB2-B7CB-7A93BA85BB44", "5EED7122-AADE-456E-954C-DDA4D0C43C3C",
      ])
    let path =
      "/api/v1/multimedia/audio?limit=2&parkCode=ever&q=alligator&sort=title&start=0&stateCode=FL"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkAudioQuery {
    try ParkAudioQuery(limit: 1, parkCodes: [ParkCode("choh")])
  }
}
