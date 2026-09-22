import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("People client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct PersonClientTests {
  @Test("An empty people page ends iteration without another request", arguments: [false, true])
  func anEmptyPeoplePageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [.success(.ok(json: try Fixture.peopleEmpty.data()))])
    let client = try makeClient(transport)
    let query = try PersonQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var people: [Person] = []
      for try await person in client.people(query: query) { people.append(person) }
      #expect(people.isEmpty)
    } else {
      var pages: [NPSCollection<Person>] = []
      for try await page in client.peoplePages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == ["/api/v1/people?limit=1&parkCode=zzzz&start=0"])
  }

  @Test("People item iteration fetches the next page only when needed")
  func peopleItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.peoplePageFirst.data())),
        .success(.ok(json: Fixture.peoplePageLast.data())),
      ])
    let sequence = try makeClient(transport).people(query: makeQuery())
    let _: NPSItemSequence<Person> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.id == "3F32B2C5-D4DB-43DA-93C6-E7D7F9419A3C")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.id == "93643143-6594-4410-B0BF-0B15D85F4B59")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/people?limit=1&parkCode=yell&start=0",
        "/api/v1/people?limit=1&parkCode=yell&start=1",
      ])
  }

  @Test("People pages advance lazily through the recorded pages")
  func peoplePagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.peoplePageFirst.data()
    let last = try Fixture.peoplePageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).peoplePages(query: makeQuery())
    let _: NPSPageSequence<Person> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<Person>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<Person>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/people?limit=1&parkCode=yell&start=0",
        "/api/v1/people?limit=1&parkCode=yell&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable people requests return the same page as their endpoint")
  func reusablePeopleRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.peopleSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try PersonQuery(
      limit: 2, parkCodes: [ParkCode("frla")], searchText: "Olmsted", stateCodes: [StateCode("MA")])
    let reusable = try await client.value(for: .people(query: query))
    let endpoint = try await client.send(.people(query: query))
    #expect(reusable == endpoint)
    #expect(
      reusable.data.map(\.id) == [
        "ECE8B2B5-41B2-4FA7-85A2-30869EFBA3E4", "F7CD73C3-F0B6-42CA-936A-D0953F3ED572",
      ])
    let path = "/api/v1/people?limit=2&parkCode=frla&q=Olmsted&start=0&stateCode=MA"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> PersonQuery {
    try PersonQuery(limit: 1, parkCodes: [ParkCode("yell")])
  }
}
