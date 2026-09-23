import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Activities client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkActivityClientTests {
  private static let firstPath =
    "/api/v1/activities?id=AE42B46C-E4B7-4889-A122-08FE180371AE,"
    + "0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=0"
  private static let lastPath =
    "/api/v1/activities?id=AE42B46C-E4B7-4889-A122-08FE180371AE,"
    + "0B685688-3405-4E2A-ABBA-E3069492EC50&limit=1&parkCode=drto&sort=-name&start=1"

  @Test(
    "An empty activities page ends iteration without another request",
    arguments: [false, true])
  func anEmptyActivitiesPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.activitiesEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try ParkActivityQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var activities: [ParkActivity] = []
      for try await activity in client.parkActivities(query: query) { activities.append(activity) }
      #expect(activities.isEmpty)
    } else {
      var pages: [NPSCollection<ParkActivity>] = []
      for try await page in client.parkActivityPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/activities?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Activities item iteration fetches the next page only when needed")
  func activitiesItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.activitiesPageFirst.data())),
        .success(.ok(json: Fixture.activitiesPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkActivities(query: makeQuery())
    let _: NPSItemSequence<ParkActivity> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "Wildlife Watching")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "Fishing")
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
  }

  @Test("Activities pages advance lazily through the recorded pages")
  func activitiesPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.activitiesPageFirst.data()
    let last = try Fixture.activitiesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkActivityPages(query: makeQuery())
    let _: NPSPageSequence<ParkActivity> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<ParkActivity>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ParkActivity>.self, from: last)))
    #expect(transport.requests.map(\.request.path) == [Self.firstPath, Self.lastPath])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable activities requests return the same page as their endpoint")
  func reusableActivitiesRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.activitiesSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkActivityQuery(
      limit: 2, parkCodes: [ParkCode("cwdw"), ParkCode("drto")], searchText: "tours",
      sort: [.descending("name")])
    let reusable = try await client.value(for: .parkActivities(query: query))
    let endpoint = try await client.send(.parkActivities(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.name) == ["Guided Tours"])
    let path = "/api/v1/activities?limit=2&parkCode=cwdw,drto&q=tours&sort=-name&start=0"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkActivityQuery {
    try ParkActivityQuery(
      identifiers: [
        NPSIdentifier("AE42B46C-E4B7-4889-A122-08FE180371AE"),
        NPSIdentifier("0B685688-3405-4E2A-ABBA-E3069492EC50"),
      ], limit: 1, parkCodes: [ParkCode("drto")], sort: [.descending("name")])
  }
}
