import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Visitor centers client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct VisitorCenterClientTests {
  @Test(
    "An empty visitor center page ends iteration without another request", arguments: [false, true])
  func anEmptyVisitorCenterPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(
      results: [.success(.ok(json: try Fixture.visitorCentersEmpty.data()))])
    let client = try makeClient(transport)
    let query = try VisitorCenterQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var centers: [VisitorCenter] = []
      for try await center in client.visitorCenters(query: query) { centers.append(center) }
      #expect(centers.isEmpty)
    } else {
      var pages: [NPSCollection<VisitorCenter>] = []
      for try await page in client.visitorCenterPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/visitorcenters?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Reusable visitor center requests return the same page as their endpoint")
  func reusableVisitorCenterRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.visitorCentersSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try VisitorCenterQuery(
      limit: 2, searchText: "museum", sort: [.ascending("name")],
      stateCodes: [StateCode("ME"), StateCode("MA")])
    let reusable = try await client.value(for: .visitorCenters(query: query))
    let endpoint = try await client.send(.visitorCenters(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "88AB3CC6-6CC5-4C62-BAC7-452F632E9177", "984C08FB-AF5E-4BD3-BE9A-7F7A8DAF5C1E",
      ])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/visitorcenters?limit=2&q=museum&sort=name&start=0&stateCode=ME,MA",
        "/api/v1/visitorcenters?limit=2&q=museum&sort=name&start=0&stateCode=ME,MA",
      ])
  }

  @Test("Visitor center item iteration fetches the next page only when needed")
  func visitorCenterItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.visitorCentersPageFirst.data())),
        .success(.ok(json: Fixture.visitorCentersPageLast.data())),
      ])
    let sequence = try makeClient(transport).visitorCenters(query: makeQuery())
    let _: NPSItemSequence<VisitorCenter> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "Acadia Gateway Center")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "Hulls Cove Visitor Center")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=0",
        "/api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=1",
      ])
  }

  @Test("Visitor center pages advance lazily through the recorded pages")
  func visitorCenterPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.visitorCentersPageFirst.data()
    let last = try Fixture.visitorCentersPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).visitorCenterPages(query: makeQuery())
    let _: NPSPageSequence<VisitorCenter> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage == (try JSONDecoder().decode(NPSCollection<VisitorCenter>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<VisitorCenter>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=0",
        "/api/v1/visitorcenters?limit=1&parkCode=acad&sort=name&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> VisitorCenterQuery {
    try VisitorCenterQuery(limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
  }
}
