import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Activity parks client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkActivityParksClientTests {
  private static let firstPath =
    "/api/v1/activities/parks?id=AE42B46C-E4B7-4889-A122-08FE180371AE,"
    + "0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=0"
  private static let lastPath =
    "/api/v1/activities/parks?id=AE42B46C-E4B7-4889-A122-08FE180371AE,"
    + "0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=1"

  @Test(
    "An empty activity parks page ends iteration without another request",
    arguments: [false, true])
  func anEmptyActivityParksPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.activityParksEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try ParkActivityParksQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var activities: [ParkActivityParks] = []
      for try await activity in client.parkActivityParks(query: query) {
        activities.append(activity)
      }
      #expect(activities.isEmpty)
    } else {
      var pages: [NPSCollection<ParkActivityParks>] = []
      for try await page in client.parkActivityParkPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/activities/parks?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Activity parks item iteration fetches the next page only when needed")
  func activityParksItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.activityParksPageFirst.data())),
        .success(.ok(json: Fixture.activityParksPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkActivityParks(query: makeQuery())
    let _: NPSItemSequence<ParkActivityParks> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "Wildlife Watching")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "Fishing")
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
  }

  @Test("Activity parks pages advance lazily through the recorded pages")
  func activityParksPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.activityParksPageFirst.data()
    let last = try Fixture.activityParksPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkActivityParkPages(query: makeQuery())
    let _: NPSPageSequence<ParkActivityParks> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage == (try JSONDecoder().decode(NPSCollection<ParkActivityParks>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(
      lastPage == (try JSONDecoder().decode(NPSCollection<ParkActivityParks>.self, from: last)))
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable activity parks requests return the same page as their endpoint")
  func reusableActivityParksRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.activityParksSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkActivityParksQuery(
      identifiers: [
        NPSIdentifier("B33DC9B6-0B7D-4322-BAD7-A13A34C584A3"),
        NPSIdentifier("0B685688-3405-4E2A-ABBA-E3069492EC50"),
      ], limit: 2, parkCodes: [ParkCode("cwdw"), ParkCode("drto")], searchText: "tours",
      sort: [.descending("name")])
    let reusable = try await client.value(for: .parkActivityParks(query: query))
    let endpoint = try await client.send(.parkActivityParks(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.name) == ["Guided Tours"])
    let path =
      "/api/v1/activities/parks?id=B33DC9B6-0B7D-4322-BAD7-A13A34C584A3,"
      + "0B685688-3405-4E2A-ABBA-E3069492EC50&limit=2&parkCode=cwdw,drto&q=tours&sort=-name"
      + "&start=0"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkActivityParksQuery {
    try ParkActivityParksQuery(
      identifiers: [
        NPSIdentifier("AE42B46C-E4B7-4889-A122-08FE180371AE"),
        NPSIdentifier("0B685688-3405-4E2A-ABBA-E3069492EC50"),
      ], limit: 1, parkCodes: [ParkCode("drto")], sort: [.descending("name")])
  }
}
