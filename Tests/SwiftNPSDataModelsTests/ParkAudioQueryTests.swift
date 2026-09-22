import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Park audio queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkAudioQueryTests {
  @Test("All documented park audio parameters preserve caller values")
  func allDocumentedParkAudioParametersPreserveCallerValues() throws {
    let query = try ParkAudioQuery(
      limit: 2, parkCodes: [ParkCode("CHOH"), ParkCode("thro")], searchText: "a +&/#?é",
      sort: [.descending("title"), .ascending("durationMs")], start: 3,
      stateCodes: [StateCode("dc"), StateCode("ND")])
    #expect(
      Endpoint.parkAudio(query: query).path
        == "/multimedia/audio?limit=2&parkCode=CHOH,thro&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-title,durationMs&start=3&stateCode=dc,ND")
    #expect(Endpoint.collection(query) == Endpoint.parkAudio(query: query))
  }

  @Test("Default park audio queries explicitly request fifty results at zero")
  func defaultParkAudioQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.parkAudio(query: ParkAudioQuery()).path == "/multimedia/audio?limit=50&start=0")
    #expect(
      try Endpoint.parkAudio(query: ParkAudioQuery(searchText: "")).path
        == "/multimedia/audio?limit=50&q=&start=0")
  }

  @Test("Empty code and sort arrays omit their parameters")
  func emptyCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ParkAudioQuery(limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.parkAudio(query: query).path == "/multimedia/audio?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid park audio query pagination is rejected")
  func invalidParkAudioQueryPaginationIsRejected() {
    #expect(throws: ParkAudioQuery.ValidationError.invalidLimit) {
      try ParkAudioQuery(limit: 0)
    }
    #expect(throws: ParkAudioQuery.ValidationError.invalidLimit) {
      try ParkAudioQuery(limit: -1)
    }
    #expect(throws: ParkAudioQuery.ValidationError.invalidStart) {
      try ParkAudioQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try ParkAudioQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.parkAudio(query: query).path
        == "/multimedia/audio?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("Park audio requests resolve as collections of the same query")
  func parkAudioRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkAudioQuery(limit: 1, parkCodes: [ParkCode("choh")])
    let request = NPSDataRequest.parkAudio(query: query)
    let _: NPSDataRequest<NPSCollection<ParkAudio>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkAudio(query: query)]).count == 1)
    #expect(request != .parkAudio(query: try ParkAudioQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkAudio(query: query))
    #expect(resolution.query as? ParkAudioQuery == query)
  }

  @Test("The recorded requests match the park audio query paths")
  func theRecordedRequestsMatchTheParkAudioQueryPaths() throws {
    let search = try ParkAudioQuery(
      limit: 2, parkCodes: [ParkCode("thro")], searchText: "Wilderness",
      sort: [.ascending("title")], stateCodes: [StateCode("ND")])
    #expect(
      Endpoint.parkAudio(query: search).path
        == "/multimedia/audio?limit=2&parkCode=thro&q=Wilderness&sort=title&start=0&stateCode=ND")
    let page = try ParkAudioQuery(limit: 1, parkCodes: [ParkCode("choh")])
    #expect(
      Endpoint.parkAudio(query: page).path == "/multimedia/audio?limit=1&parkCode=choh&start=0")
    #expect(
      Endpoint.parkAudio(query: page.starting(at: 1)).path
        == "/multimedia/audio?limit=1&parkCode=choh&start=1")
    let empty = try ParkAudioQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.parkAudio(query: empty).path == "/multimedia/audio?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A park audio query advances by the returned item count and keeps its filters")
  func aParkAudioQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ParkAudioQuery(
      limit: 1, parkCodes: [ParkCode("choh")], searchText: "canal", sort: [.ascending("title")],
      stateCodes: [StateCode("MD")])
    let page = try JSONDecoder().decode(
      NPSCollection<ParkAudio>.self, from: Fixture.parkAudioPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.parkAudio(query: next).path
        == "/multimedia/audio?limit=1&parkCode=choh&q=canal&sort=title&start=1&stateCode=MD")
  }
}
