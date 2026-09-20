import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Webcams client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct WebcamClientTests {
  @Test("An empty webcam page ends iteration without another request", arguments: [false, true])
  func anEmptyWebcamPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.webcamsEmpty.data()))])
    let client = try makeClient(transport)
    let query = try WebcamQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var webcams: [Webcam] = []
      for try await webcam in client.webcams(query: query) { webcams.append(webcam) }
      #expect(webcams.isEmpty)
    } else {
      var pages: [NPSCollection<Webcam>] = []
      for try await page in client.webcamPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == ["/api/v1/webcams?limit=1&parkCode=zzzz&start=0"])
  }

  @Test("Webcam item iteration fetches the next page only when needed")
  func webcamItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.webcamsPageFirst.data())),
        .success(.ok(json: Fixture.webcamsPageLast.data())),
      ])
    let sequence = try makeClient(transport).webcams(query: makeQuery())
    let _: NPSItemSequence<Webcam> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.isStreaming == true)
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.title == "NPS Air Resources")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/webcams?limit=1&parkCode=grte&start=0",
        "/api/v1/webcams?limit=1&parkCode=grte&start=1",
      ])
  }

  @Test("Webcam pages advance lazily through the recorded pages")
  func webcamPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.webcamsPageFirst.data()
    let last = try Fixture.webcamsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).webcamPages(query: makeQuery())
    let _: NPSPageSequence<Webcam> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<Webcam>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<Webcam>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/webcams?limit=1&parkCode=grte&start=0",
        "/api/v1/webcams?limit=1&parkCode=grte&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable webcam requests return the same page as their endpoint")
  func reusableWebcamRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.webcamsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try WebcamQuery(
      identifiers: [NPSIdentifier("9849DE2B-BC23-1110-33CED7C04E8AAF05")], limit: 2,
      parkCodes: [ParkCode("gumo")], searchText: "Capitan", stateCodes: [StateCode("TX")])
    let reusable = try await client.value(for: .webcams(query: query))
    let endpoint = try await client.send(.webcams(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.id) == ["9849DE2B-BC23-1110-33CED7C04E8AAF05"])
    let path =
      "/api/v1/webcams?id=9849DE2B-BC23-1110-33CED7C04E8AAF05&limit=2&parkCode=gumo&q=Capitan"
      + "&start=0&stateCode=TX"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> WebcamQuery {
    try WebcamQuery(limit: 1, parkCodes: [ParkCode("grte")])
  }
}
