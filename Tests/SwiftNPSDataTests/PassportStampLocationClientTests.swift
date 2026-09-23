import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Passport stamp location client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PassportStampLocationClientTests {
  @Test(
    "An empty passport stamp location page ends iteration without another request",
    arguments: [false, true])
  func anEmptyPassportStampLocationPageEndsIterationWithoutAnotherRequest(
    _ items: Bool
  ) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.passportStampLocationsEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try PassportStampLocationQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var locations: [PassportStampLocation] = []
      for try await location in client.passportStampLocations(query: query) {
        locations.append(location)
      }
      #expect(locations.isEmpty)
    } else {
      var pages: [NPSCollection<PassportStampLocation>] = []
      for try await page in client.passportStampLocationPages(query: query) {
        pages.append(page)
      }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/passportstamplocations?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Passport stamp location item iteration fetches the next page only when needed")
  func passportStampLocationItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.passportStampLocationsPageFirst.data())),
        .success(.ok(json: Fixture.passportStampLocationsPageLast.data())),
      ])
    let sequence = try makeClient(transport).passportStampLocations(query: makeQuery())
    let _: NPSItemSequence<PassportStampLocation> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.label == "Visitor Center")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.label == "Camp Misty Mount")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/passportstamplocations?id=\(ids)&limit=1&parkCode=cato&sort=-name&start=0",
        "/api/v1/passportstamplocations?id=\(ids)&limit=1&parkCode=cato&sort=-name&start=1",
      ])
  }

  @Test("Passport stamp location pages advance lazily through the recorded pages")
  func passportStampLocationPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.passportStampLocationsPageFirst.data()
    let last = try Fixture.passportStampLocationsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).passportStampLocationPages(query: makeQuery())
    let _: NPSPageSequence<PassportStampLocation> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage
        == (try JSONDecoder().decode(NPSCollection<PassportStampLocation>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(
      lastPage == (try JSONDecoder().decode(NPSCollection<PassportStampLocation>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/passportstamplocations?id=\(ids)&limit=1&parkCode=cato&sort=-name&start=0",
        "/api/v1/passportstamplocations?id=\(ids)&limit=1&parkCode=cato&sort=-name&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable passport stamp location requests return the same page as their endpoint")
  func reusablePassportStampLocationRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.passportStampLocationsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try PassportStampLocationQuery(
      limit: 3, parkCodes: [ParkCode("cagr"), ParkCode("mamc")], searchText: "national",
      sort: [.descending("name")], stateCodes: [StateCode("AZ"), StateCode("DC")])
    let reusable = try await client.value(for: .passportStampLocations(query: query))
    let endpoint = try await client.send(.passportStampLocations(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.label) == [
        "Mary McLeod Bethune Council House National Historic Site",
        "Casa Grande Ruins National Monument", "Casa Grande Ruins",
      ])
    let path =
      "/api/v1/passportstamplocations?limit=3&parkCode=cagr,mamc&q=national&sort=-name&start=0"
      + "&stateCode=AZ,DC"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private let ids = "74C8535F-4F9C-411F-B3F1-AE14E8C14AA2,9EE76DDC-80AB-4283-BCE9-F85952ED03E1"

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> PassportStampLocationQuery {
    try PassportStampLocationQuery(
      identifiers: [
        NPSIdentifier("74C8535F-4F9C-411F-B3F1-AE14E8C14AA2"),
        NPSIdentifier("9EE76DDC-80AB-4283-BCE9-F85952ED03E1"),
      ], limit: 1, parkCodes: [ParkCode("cato")], sort: [.descending("name")])
  }
}
