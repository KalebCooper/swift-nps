import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Lesson plan queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LessonPlanQueryTests {
  @Test("All documented lesson plan parameters preserve caller values")
  func allDocumentedLessonPlanParametersPreserveCallerValues() throws {
    let query = try LessonPlanQuery(
      identifiers: [NPSIdentifier("B2"), NPSIdentifier("A1")], limit: 2,
      parkCodes: [ParkCode("YELL"), ParkCode("grte")], searchText: "a +&/#?é",
      sort: [.descending("title"), .ascending("futureField")], start: 3,
      stateCodes: [StateCode("wy"), StateCode("MT")])
    #expect(
      Endpoint.lessonPlans(query: query).path
        == "/lessonplans?id=B2,A1&limit=2&parkCode=YELL,grte&q=a%20%2B%26%2F%23%3F%C3%A9"
        + "&sort=-title,futureField&start=3&stateCode=wy,MT")
    #expect(Endpoint.collection(query) == Endpoint.lessonPlans(query: query))
  }

  @Test("Default lesson plan queries explicitly request fifty results at zero")
  func defaultLessonPlanQueriesExplicitlyRequestFiftyResultsAtZero() throws {
    #expect(
      try Endpoint.lessonPlans(query: LessonPlanQuery()).path == "/lessonplans?limit=50&start=0")
    #expect(
      try Endpoint.lessonPlans(query: LessonPlanQuery(searchText: "")).path
        == "/lessonplans?limit=50&q=&start=0")
  }

  @Test("Empty lesson plan identifier, code, and sort arrays omit their parameters")
  func emptyLessonPlanIdentifierCodeAndSortArraysOmitTheirParameters() throws {
    let query = try LessonPlanQuery(
      identifiers: [], limit: 1, parkCodes: [], sort: [], stateCodes: [])
    #expect(Endpoint.lessonPlans(query: query).path == "/lessonplans?limit=1&start=0")
    #expect(query.queryItems.map(\.name) == ["limit", "start"])
  }

  @Test("Invalid lesson plan query pagination is rejected")
  func invalidLessonPlanQueryPaginationIsRejected() {
    #expect(throws: LessonPlanQuery.ValidationError.invalidLimit) { try LessonPlanQuery(limit: 0) }
    #expect(throws: LessonPlanQuery.ValidationError.invalidLimit) { try LessonPlanQuery(limit: -1) }
    #expect(throws: LessonPlanQuery.ValidationError.invalidStart) { try LessonPlanQuery(start: -1) }
  }

  @Test("Lesson plan sort fields are sent without validation or reordering")
  func lessonPlanSortFieldsAreSentWithoutValidationOrReordering() throws {
    // The live endpoint refuses relevanceScore with HTTP 400; the query still sends it as named.
    let query = try LessonPlanQuery(
      limit: 1, sort: [.descending("relevanceScore"), .ascending("title")])
    #expect(
      Endpoint.lessonPlans(query: query).path
        == "/lessonplans?limit=1&sort=-relevanceScore,title&start=0")
  }

  @Test("Lesson plan requests resolve as collections of the same query")
  func lessonPlanRequestsResolveAsCollectionsOfTheSameQuery() throws {
    let query = try LessonPlanQuery(limit: 1, parkCodes: [ParkCode("tusk")])
    let request = NPSDataRequest.lessonPlans(query: query)
    let _: NPSDataRequest<NPSCollection<LessonPlan>> = request
    #expect(request.resolution == .collection(NPSCollectionResolution(query)))
    #expect(Set([request, .lessonPlans(query: query)]).count == 1)
    #expect(request != .lessonPlans(query: try LessonPlanQuery(limit: 2)))
    guard case .collection(let resolution) = request.resolution else {
      Issue.record("A query request must resolve as a collection.")
      return
    }
    #expect(resolution.endpoint == Endpoint.lessonPlans(query: query))
    #expect(resolution.query as? LessonPlanQuery == query)
  }

  @Test("The recorded requests match the lesson plan query paths")
  func theRecordedRequestsMatchTheLessonPlanQueryPaths() throws {
    let search = try LessonPlanQuery(
      limit: 2, parkCodes: [ParkCode("grte"), ParkCode("yell")], searchText: "bear",
      stateCodes: [StateCode("WY")])
    #expect(
      Endpoint.lessonPlans(query: search).path
        == "/lessonplans?limit=2&parkCode=grte,yell&q=bear&start=0&stateCode=WY")
    let page = try LessonPlanQuery(
      limit: 1, parkCodes: [ParkCode("tusk")], searchText: "climate",
      sort: [.descending("title")])
    #expect(
      Endpoint.lessonPlans(query: page).path
        == "/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=0")
    #expect(
      Endpoint.lessonPlans(query: page.starting(at: 1)).path
        == "/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=1")
    let empty = try LessonPlanQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    #expect(Endpoint.lessonPlans(query: empty).path == "/lessonplans?limit=1&parkCode=zzzz&start=0")
  }

  @Test("A lesson plan query advances by the returned item count and keeps its filters")
  func aLessonPlanQueryAdvancesByTheReturnedItemCountAndKeepsItsFilters() throws {
    let query = try LessonPlanQuery(
      identifiers: [NPSIdentifier("A1")], limit: 1, parkCodes: [ParkCode("tusk")],
      searchText: "climate", sort: [.descending("title")], start: 0,
      stateCodes: [StateCode("NV")])
    let page = try JSONDecoder().decode(
      NPSCollection<LessonPlan>.self, from: Fixture.lessonPlansPageFirst.data())
    let next = try #require(try query.next(after: page))
    #expect(
      Endpoint.lessonPlans(query: next).path
        == "/lessonplans?id=A1&limit=1&parkCode=tusk&q=climate&sort=-title&start=1&stateCode=NV")
  }
}
