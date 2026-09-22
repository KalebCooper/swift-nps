import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Parking lot client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkingLotClientTests {
  @Test(
    "An empty parking lot page ends iteration without another request", arguments: [false, true])
  func anEmptyParkingLotPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.parkingLotsEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try ParkingLotQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var lots: [ParkingLot] = []
      for try await lot in client.parkingLots(query: query) { lots.append(lot) }
      #expect(lots.isEmpty)
    } else {
      var pages: [NPSCollection<ParkingLot>] = []
      for try await page in client.parkingLotPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/parkinglots?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Parking lot item iteration fetches the next page only when needed")
  func parkingLotItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.parkingLotsPageFirst.data())),
        .success(.ok(json: Fixture.parkingLotsPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkingLots(query: makeQuery())
    let _: NPSItemSequence<ParkingLot> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "FBB7FD7A-A735-4C34-AFBD-787548F71F5B")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "6999783B-959B-4A97-86B9-87A35638AF1E")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=0",
        "/api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=1",
      ])
  }

  @Test("Parking lot pages advance lazily through the recorded pages")
  func parkingLotPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.parkingLotsPageFirst.data()
    let last = try Fixture.parkingLotsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkingLotPages(query: makeQuery())
    let _: NPSPageSequence<ParkingLot> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<ParkingLot>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ParkingLot>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=0",
        "/api/v1/parkinglots?limit=1&parkCode=chsc&sort=-name&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable parking lot requests return the same page as their endpoint")
  func reusableParkingLotRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.parkingLotsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkingLotQuery(
      limit: 2, parkCodes: [ParkCode("havo")], searchText: "overlook",
      sort: [.ascending("name")], stateCodes: [StateCode("HI")])
    let reusable = try await client.value(for: .parkingLots(query: query))
    let endpoint = try await client.send(.parkingLots(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "A4446AB4-5566-4F6C-B218-5ED4F7C0D447", "D44DB7B9-74D1-4BDE-91CF-B2338EA69897",
      ])
    let path =
      "/api/v1/parkinglots?limit=2&parkCode=havo&q=overlook&sort=name&start=0&stateCode=HI"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkingLotQuery {
    try ParkingLotQuery(limit: 1, parkCodes: [ParkCode("chsc")], sort: [.descending("name")])
  }
}
