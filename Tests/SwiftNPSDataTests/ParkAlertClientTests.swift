import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Alerts client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkAlertClientTests {
  @Test("Alert item iteration fetches the next page only when needed")
  func alertItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.alertsPageFirst.data())),
        .success(.ok(json: Fixture.alertsPageLast.data())),
      ])
    let sequence = try makeClient(transport).parkAlerts(query: makeQuery())
    let _: NPSItemSequence<ParkAlert> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "D3E90E5C-ABED-4EDD-B17F-7D4744770978")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "F8AFCEAD-7E34-4C99-8AF6-C0B7C376C8FB")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/alerts?limit=1&parkCode=acad&start=0",
        "/api/v1/alerts?limit=1&parkCode=acad&start=1",
      ])
  }

  @Test("Alert pages advance lazily through the recorded pages")
  func alertPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.alertsPageFirst.data()
    let last = try Fixture.alertsPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).parkAlertPages(query: makeQuery())
    let _: NPSPageSequence<ParkAlert> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<ParkAlert>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<ParkAlert>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/alerts?limit=1&parkCode=acad&start=0",
        "/api/v1/alerts?limit=1&parkCode=acad&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("An empty alert page ends iteration without another request", arguments: [false, true])
  func anEmptyAlertPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.alertsEmpty.data()))])
    let client = try makeClient(transport)
    let query = try ParkAlertQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var alerts: [ParkAlert] = []
      for try await alert in client.parkAlerts(query: query) { alerts.append(alert) }
      #expect(alerts.isEmpty)
    } else {
      var pages: [NPSCollection<ParkAlert>] = []
      for try await page in client.parkAlertPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == ["/api/v1/alerts?limit=1&parkCode=zzzz&start=0"])
  }

  @Test("Reusable alert requests return the same page as their endpoint")
  func reusableAlertRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.alertsSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try ParkAlertQuery(limit: 2, parkCodes: [ParkCode("acad"), ParkCode("yell")])
    let reusable = try await client.value(for: .parkAlerts(query: query))
    let endpoint = try await client.send(.parkAlerts(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.parkCode) == ["acad", "yell"])
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/alerts?limit=2&parkCode=acad,yell&start=0",
        "/api/v1/alerts?limit=2&parkCode=acad,yell&start=0",
      ])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> ParkAlertQuery {
    try ParkAlertQuery(limit: 1, parkCodes: [ParkCode("acad")])
  }
}
