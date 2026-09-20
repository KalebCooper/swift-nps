import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Tours client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TourClientTests {
  @Test("An empty tour page ends iteration without another request", arguments: [false, true])
  func anEmptyTourPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.toursEmpty.data()))])
    let client = try makeClient(transport)
    let query = try TourQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var tours: [Tour] = []
      for try await tour in client.tours(query: query) { tours.append(tour) }
      #expect(tours.isEmpty)
    } else {
      var pages: [NPSCollection<Tour>] = []
      for try await page in client.tourPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == ["/api/v1/tours?limit=1&parkCode=zzzz&start=0"])
  }

  @Test("Tour item iteration fetches the next page only when needed")
  func tourItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.toursPageFirst.data())),
        .success(.ok(json: Fixture.toursPageLast.data())),
      ])
    let sequence = try makeClient(transport).tours(query: makeQuery())
    let _: NPSItemSequence<Tour> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.title == "Crater Rim Trail")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.title == "Crater Vent Trail")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/tours?limit=1&parkCode=cavo&start=0",
        "/api/v1/tours?limit=1&parkCode=cavo&start=1",
      ])
  }

  @Test("Tour pages advance lazily through the recorded pages")
  func tourPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.toursPageFirst.data()
    let last = try Fixture.toursPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).tourPages(query: makeQuery())
    let _: NPSPageSequence<Tour> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<Tour>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<Tour>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/tours?limit=1&parkCode=cavo&start=0",
        "/api/v1/tours?limit=1&parkCode=cavo&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable tour requests return the same page as their endpoint")
  func reusableTourRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.toursSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try TourQuery(
      identifiers: [NPSIdentifier("7F1D5880-0FE9-5B95-492B8497DB1992A1")], limit: 2,
      parkCodes: [ParkCode("foma")], searchText: "Virtual", sort: [.descending("relevanceScore")],
      stateCodes: [StateCode("FL")])
    let reusable = try await client.value(for: .tours(query: query))
    let endpoint = try await client.send(.tours(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.id) == ["7F1D5880-0FE9-5B95-492B8497DB1992A1"])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1&limit=2&parkCode=foma&q=Virtual"
          + "&sort=-relevanceScore&start=0&stateCode=FL",
        "/api/v1/tours?id=7F1D5880-0FE9-5B95-492B8497DB1992A1&limit=2&parkCode=foma&q=Virtual"
          + "&sort=-relevanceScore&start=0&stateCode=FL",
      ])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> TourQuery {
    try TourQuery(limit: 1, parkCodes: [ParkCode("cavo")])
  }
}
