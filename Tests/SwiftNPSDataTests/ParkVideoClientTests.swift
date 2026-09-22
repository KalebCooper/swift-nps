import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park video client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkVideoClientTests {
  @Test(
    "An empty park video page ends iteration without another request", arguments: [false, true])
  func anEmptyParkVideoPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.parkVideosEmpty.data()))]
    )
    let client = try makeClient(transport)
    let query = try ParkVideoQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var videos: [ParkVideo] = []
      for try await video in client.parkVideos(query: query) { videos.append(video) }
      #expect(videos.isEmpty)
    } else {
      var pages: [NPSCollection<ParkVideo>] = []
      for try await page in client.parkVideoPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/videos?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Park video item iteration fetches the next page only when needed")
  func parkVideoItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parkVideosPageFirst.data())),
        .success(.ok(json: Fixture.parkVideosPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkVideos(query: makeQuery())
    let _: NPSItemSequence<ParkVideo> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "00952400-2312-44F0-B72C-30C1C692BFF2")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "280ED23E-D17F-41C5-966E-3AB940B7AEA5")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/videos?limit=1&parkCode=crmo&start=0",
        "/api/v1/multimedia/videos?limit=1&parkCode=crmo&start=1",
      ])
  }

  @Test("Park video pages advance lazily through the recorded pages")
  func parkVideoPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.parkVideosPageFirst.data()
    let last = try Fixture.parkVideosPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkVideoPages(query: makeQuery())
    let _: NPSPageSequence<ParkVideo> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<ParkVideo>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ParkVideo>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/multimedia/videos?limit=1&parkCode=crmo&start=0",
        "/api/v1/multimedia/videos?limit=1&parkCode=crmo&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable park video requests return the same page as their endpoint")
  func reusableParkVideoRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.parkVideosSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkVideoQuery(
      limit: 2, parkCodes: [ParkCode("boaf")], searchText: "Boston",
      sort: [.ascending("title")], stateCodes: [StateCode("MA")])
    let reusable = try await client.value(for: .parkVideos(query: query))
    let endpoint = try await client.send(.parkVideos(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "33487F25-F758-4F1C-8EAB-BA420B291C8C", "A16085D7-4810-4AD5-93FB-7DD3EC92F2F2",
      ])
    let path =
      "/api/v1/multimedia/videos?limit=2&parkCode=boaf&q=Boston&sort=title&start=0&stateCode=MA"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkVideoQuery {
    try ParkVideoQuery(limit: 1, parkCodes: [ParkCode("crmo")])
  }
}
