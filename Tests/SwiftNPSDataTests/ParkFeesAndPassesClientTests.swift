import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park fees and passes client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkFeesAndPassesClientTests {
  @Test(
    "An empty fees and passes page ends iteration without another request",
    arguments: [false, true])
  func anEmptyFeesAndPassesPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.parkFeesAndPassesEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try ParkFeesAndPassesQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var records: [ParkFeesAndPasses] = []
      for try await record in client.parkFeesAndPasses(query: query) { records.append(record) }
      #expect(records.isEmpty)
    } else {
      var pages: [NPSCollection<ParkFeesAndPasses>] = []
      for try await page in client.parkFeesAndPassesPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/feespasses?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Fees and passes item iteration fetches the next page only when needed")
  func feesAndPassesItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parkFeesAndPassesPageFirst.data())),
        .success(.ok(json: Fixture.parkFeesAndPassesPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkFeesAndPasses(query: makeQuery())
    let _: NPSItemSequence<ParkFeesAndPasses> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.parkCode == "havo")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.parkCode == "hale")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=0",
        "/api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=1",
      ])
  }

  @Test("Fees and passes pages advance lazily through the recorded pages")
  func feesAndPassesPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.parkFeesAndPassesPageFirst.data()
    let last = try Fixture.parkFeesAndPassesPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkFeesAndPassesPages(query: makeQuery())
    let _: NPSPageSequence<ParkFeesAndPasses> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(
      firstPage == (try JSONDecoder().decode(NPSCollection<ParkFeesAndPasses>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(
      lastPage == (try JSONDecoder().decode(NPSCollection<ParkFeesAndPasses>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=0",
        "/api/v1/feespasses?limit=1&parkCode=hale,havo&sort=-parkCode&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable fees and passes requests return the same page as their endpoint")
  func reusableFeesAndPassesRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.parkFeesAndPassesSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkFeesAndPassesQuery(
      limit: 2, parkCodes: [ParkCode("deva"), ParkCode("fova")], searchText: "annual",
      stateCodes: [StateCode("CA"), StateCode("WA")])
    let reusable = try await client.value(for: .parkFeesAndPasses(query: query))
    let endpoint = try await client.send(.parkFeesAndPasses(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.parkCode) == ["deva", "fova"])
    let path =
      "/api/v1/feespasses?limit=2&parkCode=deva,fova&q=annual&start=0&stateCode=CA,WA"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkFeesAndPassesQuery {
    try ParkFeesAndPassesQuery(
      limit: 1, parkCodes: [ParkCode("hale"), ParkCode("havo")], sort: [.descending("parkCode")])
  }
}
