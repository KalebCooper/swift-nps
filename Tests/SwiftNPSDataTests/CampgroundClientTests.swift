import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Campgrounds client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct CampgroundClientTests {
  @Test(
    "An empty campground page ends iteration without another request", arguments: [false, true])
  func anEmptyCampgroundPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(
      results: [.success(.ok(json: try Fixture.campgroundsEmpty.data()))])
    let client = try makeClient(transport)
    let query = try CampgroundQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var campgrounds: [Campground] = []
      for try await campground in client.campgrounds(query: query) {
        campgrounds.append(campground)
      }
      #expect(campgrounds.isEmpty)
    } else {
      var pages: [NPSCollection<Campground>] = []
      for try await page in client.campgroundPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/campgrounds?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Campground item iteration fetches the next page only when needed")
  func campgroundItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.campgroundsPageFirst.data())),
        .success(.ok(json: Fixture.campgroundsPageLast.data())),
      ])
    let sequence = try makeClient(transport).campgrounds(query: makeQuery())
    let _: NPSItemSequence<Campground> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.name == "Blackwoods Campground")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.name == "Duck Harbor Campground")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=0",
        "/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=1",
      ])
  }

  @Test("Campground pages advance lazily through the recorded pages")
  func campgroundPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.campgroundsPageFirst.data()
    let last = try Fixture.campgroundsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).campgroundPages(query: makeQuery())
    let _: NPSPageSequence<Campground> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage == (try JSONDecoder().decode(NPSCollection<Campground>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<Campground>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=0",
        "/api/v1/campgrounds?limit=1&parkCode=acad&sort=name&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable campground requests return the same page as their endpoint")
  func reusableCampgroundRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.campgroundsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try CampgroundQuery(
      limit: 2, searchText: "lake", sort: [.ascending("name")],
      stateCodes: [StateCode("WY")])
    let reusable = try await client.value(for: .campgrounds(query: query))
    let endpoint = try await client.send(.campgrounds(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "4F9ED6A5-3ED1-443D-9E4C-859D7988F199", "4EAF0F61-6361-4CAC-BB23-F93C5CF4A8E2",
      ])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/campgrounds?limit=2&q=lake&sort=name&start=0&stateCode=WY",
        "/api/v1/campgrounds?limit=2&q=lake&sort=name&start=0&stateCode=WY",
      ])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> CampgroundQuery {
    try CampgroundQuery(limit: 1, parkCodes: [ParkCode("acad")], sort: [.ascending("name")])
  }
}
