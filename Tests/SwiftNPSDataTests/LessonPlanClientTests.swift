import Foundation
import HTTPCore
import HTTPTesting
import HTTPTypes
import SwiftNPSData
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Lesson plan client", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct LessonPlanClientTests {
  @Test(
    "An empty lesson plan page ends iteration without another request",
    arguments: [false, true])
  func anEmptyLessonPlanPageEndsIterationWithoutAnotherRequest(_ items: Bool) async throws {
    let transport = MockTransport(results: [
      .success(.ok(json: try Fixture.lessonPlansEmpty.data()))
    ])
    let client = try makeClient(transport)
    let query = try LessonPlanQuery(limit: 1, parkCodes: [ParkCode("zzzz")])
    if items {
      var plans: [LessonPlan] = []
      for try await plan in client.lessonPlans(query: query) { plans.append(plan) }
      #expect(plans.isEmpty)
    } else {
      var pages: [NPSCollection<LessonPlan>] = []
      for try await page in client.lessonPlanPages(query: query) { pages.append(page) }
      #expect(pages.map(\.total) == ["0"])
      #expect(pages.first?.data.isEmpty == true)
    }
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/lessonplans?limit=1&parkCode=zzzz&start=0"
      ])
  }

  @Test("Lesson plan item iteration fetches the next page only when needed")
  func lessonPlanItemIterationFetchesTheNextPageOnlyWhenNeeded() async throws {
    let transport = MockTransport(
      results: try [
        .success(.ok(json: Fixture.lessonPlansPageFirst.data())),
        .success(.ok(json: Fixture.lessonPlansPageLast.data())),
      ])
    let sequence = try makeClient(transport).lessonPlans(query: makeQuery())
    let _: NPSItemSequence<LessonPlan> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    #expect(try await iterator.next()?.title == "Climate Change: Past, Present, and Future")
    #expect(transport.requests.count == 1)
    #expect(try await iterator.next()?.title == "Climate Change & Bird Range")
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=0",
        "/api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=1",
      ])
  }

  @Test("Lesson plan pages advance lazily through the recorded pages")
  func lessonPlanPagesAdvanceLazilyThroughTheRecordedPages() async throws {
    let first = try Fixture.lessonPlansPageFirst.data()
    let last = try Fixture.lessonPlansPageLast.data()
    let transport = MockTransport(results: [.success(.ok(json: first)), .success(.ok(json: last))])
    let sequence = try makeClient(transport).lessonPlanPages(query: makeQuery())
    let _: NPSPageSequence<LessonPlan> = sequence
    var iterator = sequence.makeAsyncIterator()
    #expect(transport.requests.isEmpty)
    let firstPage = try await iterator.next()
    #expect(firstPage == (try JSONDecoder().decode(NPSCollection<LessonPlan>.self, from: first)))
    #expect(transport.requests.count == 1)
    let lastPage = try await iterator.next()
    #expect(lastPage == (try JSONDecoder().decode(NPSCollection<LessonPlan>.self, from: last)))
    #expect(
      transport.requests.map(\.request.path) == [
        "/api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=0",
        "/api/v1/lessonplans?limit=1&parkCode=tusk&q=climate&sort=-title&start=1",
      ])
    let key = try #require(HTTPField.Name("X-Api-Key"))
    for call in transport.requests {
      #expect(call.request.authority == "developer.nps.gov")
      #expect(call.request.headerFields[key] == "private-test-key")
    }
  }

  @Test("Reusable lesson plan requests return the same page as their endpoint")
  func reusableLessonPlanRequestsReturnTheSamePageAsTheirEndpoint() async throws {
    let body = try Fixture.lessonPlansSearch.data()
    let transport = MockTransport(results: [.success(.ok(json: body)), .success(.ok(json: body))])
    let client = try makeClient(transport)
    let query = try LessonPlanQuery(
      limit: 2, parkCodes: [ParkCode("grte"), ParkCode("yell")], searchText: "bear",
      stateCodes: [StateCode("WY")])
    let reusable = try await client.value(for: .lessonPlans(query: query))
    let endpoint = try await client.send(.lessonPlans(query: query))
    #expect(reusable == endpoint)
    #expect(reusable.data.map(\.title) == ["A Bear's Menu", "Invent an Animal"])
    let path = "/api/v1/lessonplans?limit=2&parkCode=grte,yell&q=bear&start=0&stateCode=WY"
    #expect(transport.requests.map(\.request.path) == [path, path])
  }

  private func makeClient(_ transport: MockTransport) throws(NPSDataError) -> NPSDataClient {
    NPSDataClient(
      configuration: try NPSDataConfiguration(apiKey: "private-test-key"), transport: transport)
  }

  private func makeQuery() throws -> LessonPlanQuery {
    try LessonPlanQuery(
      limit: 1, parkCodes: [ParkCode("tusk")], searchText: "climate",
      sort: [.descending("title")])
  }
}
