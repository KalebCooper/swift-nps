import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Topics queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkTopicQueryTests {
  @Test("All documented topics parameters preserve caller values")
  func allDocumentedTopicsParametersPreserveCallerValues() throws {
    let query = try ParkTopicQuery(
      identifiers: [NPSIdentifier("B2"), NPSIdentifier("A1")], limit: 2,
      parkCodes: [ParkCode("DRTO"), ParkCode("cwdw")], searchText: "a +&/#?é",
      sort: [.descending("name"), .ascending("id")], start: 3)
    #expect(
      Endpoint.parkTopics(query: query).path
        == "/topics?id=B2,A1&limit=2&parkCode=DRTO,cwdw&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-name,id&start=3")
    #expect(Endpoint.collection(query) == Endpoint.parkTopics(query: query))
  }

  @Test("Default topics queries explicitly request fifty results at zero")
  func defaultTopicsQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.parkTopics(query: ParkTopicQuery()).path == "/topics?limit=50&start=0")
    #expect(
      try Endpoint.parkTopics(query: ParkTopicQuery(searchText: "")).path
        == "/topics?limit=50&q=&start=0")
  }

  @Test("Empty topics identifier, code, and sort arrays omit their parameters")
  func emptyTopicsIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ParkTopicQuery(identifiers: [], limit: 1, parkCodes: [], sort: [])
    #expect(Endpoint.parkTopics(query: query).path == "/topics?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid topics query pagination is rejected")
  func invalidTopicsQueryPaginationIsRejected() {
    #expect(throws: ParkTopicQuery.ValidationError.invalidLimit) {
      try ParkTopicQuery(limit: 0)
    }
    #expect(throws: ParkTopicQuery.ValidationError.invalidLimit) {
      try ParkTopicQuery(limit: -1)
    }
    #expect(throws: ParkTopicQuery.ValidationError.invalidStart) {
      try ParkTopicQuery(start: -1)
    }
  }

  @Test("Topics sort fields are sent without validation or reordering")
  func topicsSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try ParkTopicQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("futureField")])
    #expect(
      Endpoint.parkTopics(query: query).path
        == "/topics?limit=1&sort=-relevanceScore,futureField&start=0")
  }

  @Test("Topics requests resolve as collections of the same query")
  func topicsRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ParkTopicQuery(limit: 1, parkCodes: [ParkCode("mamc")])
    let request = NPSDataRequest.parkTopics(query: query)
    let _: NPSDataRequest<NPSCollection<ParkTopic>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .parkTopics(query: query)]).count == 1)
    #expect(request != .parkTopics(query: try ParkTopicQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.parkTopics(query: query))
    #expect(resolution.query as? ParkTopicQuery == query)
  }

  @Test("The recorded requests match the topics query paths")
  func theRecordedRequestsMatchTheTopicsQueryPaths() throws {
    let africanAmericanHeritage = "28AEAE85-9DDA-45B6-981B-1CFCDCC61E14"
    let womensHistory = "7DA81DAB-5045-4953-9C20-36590AD9FA95"
    let search = try ParkTopicQuery(
      limit: 2, parkCodes: [ParkCode("acad"), ParkCode("mamc")], searchText: "history",
      sort: [.descending("name")])
    #expect(
      Endpoint.parkTopics(query: search).path
        == "/topics?limit=2&parkCode=acad,mamc&q=history&sort=-name&start=0")
    let page = try ParkTopicQuery(
      identifiers: [NPSIdentifier(africanAmericanHeritage), NPSIdentifier(womensHistory)],
      limit: 1, parkCodes: [ParkCode("mamc")], sort: [.descending("name")])
    #expect(
      Endpoint.parkTopics(query: page).path
        == "/topics?id=\(africanAmericanHeritage),\(womensHistory)&limit=1&parkCode=mamc"
        + "&sort=-name&start=0")
    #expect(
      Endpoint.parkTopics(query: page.starting(at: 1)).path
        == "/topics?id=\(africanAmericanHeritage),\(womensHistory)&limit=1&parkCode=mamc"
        + "&sort=-name&start=1")
    let empty = try ParkTopicQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(
      Endpoint.parkTopics(query: empty).path == "/topics?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A topics query advances by the returned item count and keeps its filters")
  func aTopicsQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try ParkTopicQuery(
      identifiers: [NPSIdentifier("A1"), NPSIdentifier("B2")], limit: 1,
      parkCodes: [ParkCode("mamc")], searchText: "heritage",
      sort: [.descending("name"), .ascending("id")], start: 0)
    let page = try JSONDecoder().decode(
      NPSCollection<ParkTopic>.self, from: Fixture.topicsPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.parkTopics(query: next).path
        == "/topics?id=A1,B2&limit=1&parkCode=mamc&q=heritage&sort=-name,id&start=1")
  }
}
