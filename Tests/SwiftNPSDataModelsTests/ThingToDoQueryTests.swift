import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Things to do queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ThingToDoQueryTests {
  @Test("All documented things to do parameters preserve caller values")
  func allDocumentedThingsToDoParametersPreserveCallerValues() throws {
    let query = try ThingToDoQuery(
      identifiers: [
        NPSIdentifier("C54D2783-6F50-4E03-9010-FCDA5C31EE91"), NPSIdentifier("future,id&x"),
      ],
      limit: 2, parkCodes: [ParkCode("ACAD"), ParkCode("yell")], searchText: "a +&/#?é",
      sort: [.descending("relevanceScore"), .ascending("title")], start: 3,
      stateCodes: [StateCode("me"), StateCode("WY")])
    #expect(
      Endpoint.thingsToDo(query: query).path
        == "/thingstodo?id=C54D2783-6F50-4E03-9010-FCDA5C31EE91,future%2Cid%26x&limit=2"
        + "&parkCode=ACAD,yell&q=a%20%2B%26%2F%23%3F%C3%A9&sort=-relevanceScore,title&start=3"
        + "&stateCode=me,WY")
    #expect(Endpoint.collection(query) == Endpoint.thingsToDo(query: query))
  }

  @Test("Default things to do queries explicitly request fifty results at zero")
  func defaultThingsToDoQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.thingsToDo(query: ThingToDoQuery()).path == "/thingstodo?limit=50&start=0")
    #expect(
      try Endpoint.thingsToDo(query: ThingToDoQuery(searchText: "")).path
        == "/thingstodo?limit=50&q=&start=0")
  }

  @Test("Empty identifier, code, and sort arrays omit their parameters")
  func emptyIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try ThingToDoQuery(
      identifiers: [], limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.thingsToDo(query: query).path == "/thingstodo?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test(
    "Identifiers preserve case and accept unknown values",
    arguments: [
      "C54D2783-6F50-4E03-9010-FCDA5C31EE91", "c54d2783-6f50-4e03-9010-fcda5c31ee91", "1", "a,b",
      "é", "future/id",
    ])
  func identifiersPreserveCaseAndAcceptUnknownValues(_ value: String) throws {
    #expect(try NPSIdentifier(value).rawValue == value)
  }

  @Test(
    "Identifiers reject empty text, whitespace, and control characters",
    arguments: [
      "", " ", " A1", "A1 ", "A 1", "A\t1", "A\n1", "A\u{00A0}1", "A\u{0000}1", "A\u{007F}1",
    ])
  func identifiersRejectEmptyTextWhitespaceAndControlCharacters(_ value: String) {
    #expect(throws: NPSIdentifier.ValidationError.invalidValue) { try NPSIdentifier(value) }
  }

  @Test("Invalid things to do query pagination is rejected")
  func invalidThingsToDoQueryPaginationIsRejected() {
    #expect(throws: ThingToDoQuery.ValidationError.invalidLimit) {
      try ThingToDoQuery(limit: 0)
    }
    #expect(throws: ThingToDoQuery.ValidationError.invalidLimit) {
      try ThingToDoQuery(limit: -1)
    }
    #expect(throws: ThingToDoQuery.ValidationError.invalidStart) {
      try ThingToDoQuery(start: -1)
    }
  }

  @Test("Sort fields are sent without validation or reordering")
  func sortFieldsAreSentWithoutValidationOrReordering() throws {
    // NPS documents only relevanceScore and answers title with HTTP 400; the query does not decide.
    let query = try ThingToDoQuery(
      limit: 1, sort: [.ascending("title"), .descending("futureField")])
    #expect(
      Endpoint.thingsToDo(query: query).path
        == "/thingstodo?limit=1&sort=title,-futureField&start=0")
  }

  @Test("The recorded requests match the things to do query paths")
  func theRecordedRequestsMatchTheThingsToDoQueryPaths() throws {
    let search = try ThingToDoQuery(
      limit: 2, searchText: "hike", sort: [.descending("relevanceScore")],
      stateCodes: [StateCode("ME")])
    #expect(
      Endpoint.thingsToDo(query: search).path
        == "/thingstodo?limit=2&q=hike&sort=-relevanceScore&start=0&stateCode=ME")
    let page = try ThingToDoQuery(
      limit: 1, parkCodes: [ParkCode("acad")], sort: [.descending("relevanceScore")])
    #expect(
      Endpoint.thingsToDo(query: page).path
        == "/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=0")
    #expect(
      Endpoint.thingsToDo(query: page.starting(at: 1)).path
        == "/thingstodo?limit=1&parkCode=acad&sort=-relevanceScore&start=1")
    #expect(
      try Endpoint.thingsToDo(query: ThingToDoQuery(limit: 1, parkCodes: [ParkCode("zzzz")])).path
        == "/thingstodo?limit=1&parkCode=zzzz&start=0")
  }

  @Test("Things to do requests resolve as collections of the same query")
  func thingsToDoRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try ThingToDoQuery(
      identifiers: [NPSIdentifier("C54D2783-6F50-4E03-9010-FCDA5C31EE91")], limit: 1)
    let request = NPSDataRequest.thingsToDo(query: query)
    let _: NPSDataRequest<NPSCollection<ThingToDo>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .thingsToDo(query: query)]).count == 1)
    #expect(request != .thingsToDo(query: try ThingToDoQuery(limit: 1)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.thingsToDo(query: query))
    #expect(resolution.query as? ThingToDoQuery == query)
  }
}
