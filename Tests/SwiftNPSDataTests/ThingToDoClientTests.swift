import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Things to do client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ThingToDoClientTests {
  @Test(
    "An empty things to do page ends iteration without another request", arguments: [false, true])
  func anEmptyThingsToDoPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(
      results: [.success(.ok(json: try Fixture.thingsToDoEmpty.data()))])
    let client = try makeClient(transport)
    let query = try ThingToDoQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var things: [ThingToDo] = []
      for try await thing in client.thingsToDo(query: query) { things.append(thing) }
      #expect(things.isEmpty)
    } else {
      var pages: [NPSCollection<ThingToDo>] = []
      for try await page in client.thingToDoPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/thingstodo?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Reusable things to do requests return the same page as their endpoint")
  func reusableThingsToDoRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.thingsToDoSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ThingToDoQuery(
      limit: 2, searchText: "hike", sort: [.descending("relevanceScore")],
      stateCodes: [StateCode("ME")])
    let reusable = try await client.value(for: .thingsToDo(query: query))
    let endpoint = try await client.send(.thingsToDo(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "51F69951-0A1B-4D54-AEAC-499B53C8A31F", "E6CE83A1-421D-4B0C-9404-782FCD87228F",
      ])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/thingstodo?limit=2&q=hike&sort=-relevanceScore&start=0&stateCode=ME",
        "/api/v1/thingstodo?limit=2&q=hike&sort=-relevanceScore&start=0&stateCode=ME",
      ])
  }

  @Test("Things to do item iteration fetches the next page only when needed")
  func thingsToDoItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.thingsToDoPageFirst.data())),
        .success(.ok(json: Fixture.thingsToDoPageLast.data())),
      ])
    let sequence = try makeClient(transport).thingsToDo(query: makeQuery())
    let _: NPSItemSequence<ThingToDo> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.title == "Bike Carriage Roads")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.title == #"Birding "with" the Champlain Society"#)
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0",
        "/api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=1",
      ])
  }

  @Test("Things to do pages advance lazily through the recorded pages")
  func thingsToDoPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.thingsToDoPageFirst.data()
    let last = try Fixture.thingsToDoPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).thingToDoPages(query: makeQuery())
    let _: NPSPageSequence<ThingToDo> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage == (try JSONDecoder().decode(NPSCollection<ThingToDo>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ThingToDo>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0",
        "/api/v1/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=1",
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

  private func makeQuery() throws -> ThingToDoQuery {
    try ThingToDoQuery(
      limit: 1, parkCodes: [ParkCode("acad")], sort: [.descending("relevanceScore")])
  }
}
