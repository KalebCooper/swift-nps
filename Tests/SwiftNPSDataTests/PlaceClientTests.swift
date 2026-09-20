import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Places client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PlaceClientTests {
  @Test("An empty place page ends iteration without another request", arguments: [false, true])
  func anEmptyPlacePageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.placesEmpty.data()))])
    let client = try makeClient(transport)
    let query = try PlaceQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var places: [Place] = []
      for try await place in client.places(query: query) { places.append(place) }
      #expect(places.isEmpty)
    } else {
      var pages: [NPSCollection<Place>] = []
      for try await page in client.placePages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == ["/api/v1/places?limit=1&parkCode=zzzz&start=0"])
  }

  @Test("Place item iteration fetches the next page only when needed")
  func placeItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.placesPageFirst.data())),
        .success(.ok(json: Fixture.placesPageLast.data())),
      ])
    let sequence = try makeClient(transport).places(query: makeQuery())
    let _: NPSItemSequence<Place> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(
      try await iterator.next()?.title == "Acadia Earthcache Course Stop Five: Champlain Mountain")
    #expect(transport.requests.count == 1)
    #expect(
      try await iterator.next()?.title
        == "Acadia Earthcache Course Stop Four: Gorham Mountain Trail")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/places?limit=1&parkCode=acad&start=0",
        "/api/v1/places?limit=1&parkCode=acad&start=1",
      ])
  }

  @Test("Place pages advance lazily through the recorded pages")
  func placePagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.placesPageFirst.data()
    let last = try Fixture.placesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).placePages(query: makeQuery())
    let _: NPSPageSequence<Place> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<Place>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<Place>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/places?limit=1&parkCode=acad&start=0",
        "/api/v1/places?limit=1&parkCode=acad&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable place requests return the same page as their endpoint")
  func reusablePlaceRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.placesSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try PlaceQuery(
      limit: 2, searchText: "Redoubt", stateCodes: [StateCode("FL")])
    let reusable = try await client.value(for: .places(query: query))
    let endpoint = try await client.send(.places(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "80F024C5-27B0-48B7-8098-30E10EE5AB61", "02E85F7F-2454-4B71-9372-AD71813FA80B",
      ])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/places?limit=2&q=Redoubt&start=0&stateCode=FL",
        "/api/v1/places?limit=2&q=Redoubt&start=0&stateCode=FL",
      ])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> PlaceQuery {
    try PlaceQuery(limit: 1, parkCodes: [ParkCode("acad")])
  }
}
