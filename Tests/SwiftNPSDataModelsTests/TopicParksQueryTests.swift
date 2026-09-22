import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Topic parks queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct TopicParksQueryTests {
  @Test("All documented topic parks parameters preserve caller values")
  func allDocumentedTopicParksParametersPreserveCallerValues() throws {
    let query = try TopicParksQuery(
      identifiers: [NPSIdentifier("B2"), NPSIdentifier("A1")], limit: 2,
      parkCodes: [ParkCode("MAMC"), ParkCode("acad")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("id")], start: 3)
    #expect(
      Endpoint.topicParks(query: query).path
        == "/topics/parks?id=B2,A1&limit=2&parkCode=MAMC,acad&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,id&start=3")
    #expect(Endpoint.collection(query) == Endpoint.topicParks(query: query))
  }

  @Test("Default topic parks queries explicitly request fifty results at zero")
  func defaultTopicParksQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.topicParks(query: TopicParksQuery()).path == "/topics/parks?limit=50&start=0")
    #expect(
      try Endpoint.topicParks(query: TopicParksQuery(searchText: "")).path
        == "/topics/parks?limit=50&q=&start=0")
  }

  @Test("Empty topic parks identifier, code, and sort arrays omit their parameters")
  func emptyTopicParksIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try TopicParksQuery(identifiers: [], limit: 1, parkCodes: [], sort: [])
    #expect(Endpoint.topicParks(query: query).path == "/topics/parks?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid topic parks query pagination is rejected")
  func invalidTopicParksQueryPaginationIsRejected() {
    #expect(throws: TopicParksQuery.ValidationError.invalidLimit) {
      try TopicParksQuery(limit: 0)
    }
    #expect(throws: TopicParksQuery.ValidationError.invalidLimit) {
      try TopicParksQuery(limit: -1)
    }
    #expect(throws: TopicParksQuery.ValidationError.invalidStart) {
      try TopicParksQuery(start: -1)
    }
  }

  @Test("Topic parks sort fields are sent without validation or reordering")
  func topicParksSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses parkCode with HTTP 400; the query still sends it as named.
    let query = try TopicParksQuery(
      limit: 1, sort: [.descending("parkCode"), .ascending("futureField")])
    #expect(
      Endpoint.topicParks(query: query).path
        == "/topics/parks?limit=1&sort=-parkCode,futureField&start=0")
  }

  @Test("Topic parks requests resolve as collections of the same query")
  func topicParksRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try TopicParksQuery(limit: 1, parkCodes: [ParkCode("mamc")])
    let request = NPSDataRequest.topicParks(query: query)
    let _: NPSDataRequest<NPSCollection<TopicParks>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .topicParks(query: query)]).count == 1)
    #expect(request != .topicParks(query: try TopicParksQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.topicParks(query: query))
    #expect(resolution.query as? TopicParksQuery == query)
  }

  @Test("The recorded requests match the topic parks query paths")
  func theRecordedRequestsMatchTheTopicParksQueryPaths() throws {
    let heritage = "28AEAE85-9DDA-45B6-981B-1CFCDCC61E14"
    let history = "7DA81DAB-5045-4953-9C20-36590AD9FA95"
    let search = try TopicParksQuery(
      identifiers: [NPSIdentifier(heritage), NPSIdentifier(history)], limit: 2,
      parkCodes: [ParkCode("acad"), ParkCode("mamc")], searchText: "history",
      sort: [.descending("name")])
    #expect(
      Endpoint.topicParks(query: search).path
        == "/topics/parks?id=\(heritage),\(history)&limit=2&parkCode=acad,mamc&q=history"
        + "&sort=-name&start=0")
    let page = try TopicParksQuery(
      identifiers: [NPSIdentifier(heritage), NPSIdentifier(history)], limit: 1,
      parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
    #expect(
      Endpoint.topicParks(query: page).path
        == "/topics/parks?id=\(heritage),\(history)&limit=1&parkCode=mamc&sort=-name&start=0")
    #expect(
      Endpoint.topicParks(query: page.starting(at: 1)).path
        == "/topics/parks?id=\(heritage),\(history)&limit=1&parkCode=mamc&sort=-name&start=1")
    let empty = try TopicParksQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(Endpoint.topicParks(query: empty).path == "/topics/parks?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A topic parks query advances by the returned item count and keeps its filters")
  func aTopicParksQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try TopicParksQuery(
      identifiers: [NPSIdentifier("A1"), NPSIdentifier("B2")], limit: 1,
      parkCodes: [ParkCode("mamc")], searchText: "heritage",
      sort: [.descending("name"), .ascending("id")], start: 0)
    let page = try JSONDecoder().decode(
      NPSCollection<TopicParks>.self, from: Fixture.topicParksPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.topicParks(query: next).path
        == "/topics/parks?id=A1,B2&limit=1&parkCode=mamc&q=heritage&sort=-name,id&start=1")
  }
}
