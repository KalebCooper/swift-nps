import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Event requests", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkEventRequestTests {
  @Test("Event requests retain inference equality and inspectable continuation")
  func eventRequestsRetainInferenceEqualityAndInspectableContinuation() throws {
    let query = try ParkEventQuery(pageSize: 2, parkCodes: [ParkCode("yell")])
    let request = NPSDataRequest.parkEvents(query: query)
    let _: NPSDataRequest<ParkEventCollection> = request
    #expect(request == .parkEvents(query: query))
    #expect(Set([request, .parkEvents(query: query)]).count == 1)
    #expect(request != .parkEvents(query: try ParkEventQuery(pageSize: 2, searchText: "other")))
    #expect(request != .parkEvents(query: try ParkEventQuery(expandRecurring: true, pageSize: 2)))
    guard case .parkEvents(let resolution) = request.resolution else {
      Issue.record("Expected an events resolution.")
      return
    }
    #expect(resolution.query == query)
    #expect(resolution.endpoint == .parkEvents(query: query))
    let first = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsPageFirst.data())
    let next = try #require(try resolution.next(after: first))
    #expect(next.query.pageNumber == 2)
    let last = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsPageLast.data())
    #expect(try next.next(after: last) == nil)
  }
}
