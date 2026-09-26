import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Event continuation", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkEventContinuationTests {
  @Test("Continuation retains every filter and advances exactly one page")
  func continuationRetainsEveryFilterAndAdvancesExactlyOnePage() throws {
    let query = try ParkEventQuery(
      dateEnd: .init("2026-10-07"), dateStart: .init("2026-10-01"), eventTypes: ["Talk"],
      identifier: "one", organizations: ["im"], pageSize: 2, parkCodes: [ParkCode("yell")],
      portals: ["parks"], searchText: "a & b", stateCodes: [StateCode("WY")],
      tagsAll: ["a"], tagsNone: ["b"], tagsOne: ["c"])
    let response = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsPageFirst.data())
    let next = try #require(try query.next(after: response))
    #expect(next.pageNumber == 2)
    #expect(
      next.queryItems.filter { $0.name != "pageNumber" }
        == query.queryItems.filter { $0.name != "pageNumber" })
    #expect(
      Endpoint.parkEvents(query: next).path
        == "/events?dateEnd=2026-10-07&dateStart=2026-10-01&eventType=Talk&expandRecurring=false&id=one&organization=im&pageNumber=2&pageSize=2&parkCode=yell&portal=parks&q=a%20%26%20b&stateCode=WY&tagsAll=a&tagsNone=b&tagsOne=c"
    )
  }

  @Test("Expanded continuation fails instead of guessing completion")
  func expandedContinuationFailsInsteadOfGuessingCompletion() throws {
    let expanded = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsExpanded.data())
    let query = try ParkEventQuery(expandRecurring: true)
    #expect(throws: NPSPaginationError.eventExpansionUnavailable) {
      try query.next(after: expanded)
    }
    #expect(throws: NPSPaginationError.eventExpansionUnavailable) {
      try ParkEventQuery().next(after: expanded)
    }
  }

  @Test(
    "Malformed numeric metadata never silently completes",
    arguments: ["", "-1", "+1", "1.0", " 1", "１", "9999999999999999999999999"])
  func malformedNumericMetadataNeverSilentlyCompletes(_ value: String) throws {
    for field in ["pagenumber", "pagesize", "total"] {
      var metadata = ["pagenumber": "1", "pagesize": "2", "total": "2"]
      metadata[field] = value
      let response = try Self.page(metadata, count: 2)
      #expect(throws: NPSPaginationError.invalidMetadata(field: field, value: value)) {
        try ParkEventQuery(pageSize: 2).next(after: response)
      }
    }
  }

  @Test("Page validation rejects wrong echoes inconsistent counts and overflow")
  func pageValidationRejectsWrongEchoesInconsistentCountsAndOverflow() throws {
    let query = try ParkEventQuery(pageSize: 2)
    #expect(throws: NPSPaginationError.unexpectedPageNumber(actual: 2, expected: 1)) {
      try query.next(
        after: Self.page(["pagenumber": "2", "pagesize": "2", "total": "4"], count: 2))
    }
    #expect(throws: NPSPaginationError.unexpectedPageSize(actual: 1, expected: 2)) {
      try query.next(
        after: Self.page(["pagenumber": "1", "pagesize": "1", "total": "1"], count: 1))
    }
    for field in ["pagenumber", "pagesize"] {
      var metadata = ["pagenumber": "1", "pagesize": "2", "total": "0"]
      metadata[field] = "0"
      #expect(throws: NPSPaginationError.invalidMetadata(field: field, value: "0")) {
        try query.next(after: Self.page(metadata, count: 0))
      }
    }
    for (count, total) in [(0, 3), (1, 3), (3, 3), (2, 1)] {
      #expect(throws: NPSPaginationError.inconsistentPage) {
        try query.next(
          after: Self.page(
            ["pagenumber": "1", "pagesize": "2", "total": String(total)], count: count))
      }
    }
    #expect(throws: NPSPaginationError.offsetOverflow) {
      try ParkEventQuery(pageNumber: Int.max, pageSize: 2).next(
        after:
          Self.page(
            ["pagenumber": String(Int.max), "pagesize": "2", "total": String(Int.max)], count: 2))
    }
    let number = Int.max / 2 + 1
    #expect(throws: NPSPaginationError.offsetOverflow) {
      try ParkEventQuery(pageNumber: number, pageSize: 2).next(
        after:
          Self.page(
            ["pagenumber": String(number), "pagesize": "2", "total": String(Int.max)], count: 2))
    }
  }

  @Test("Recorded terminal pages support arbitrary starting pages")
  func recordedTerminalPagesSupportArbitraryStartingPages() throws {
    for (fixture, number, size) in [
      (Fixture.eventsPageLast, 2, 2), (.eventsFullTerminal, 1, 3),
      (.eventsBeyond, 2, 10), (.eventsEmpty, 1, 50),
    ] {
      let response = try JSONDecoder().decode(ParkEventCollection.self, from: fixture.data())
      #expect(try ParkEventQuery(pageNumber: number, pageSize: size).next(after: response) == nil)
    }
    let response = try Self.page(["pagenumber": "3", "pagesize": "2", "total": "8"], count: 2)
    #expect(try ParkEventQuery(pageNumber: 3, pageSize: 2).next(after: response)?.pageNumber == 4)
    let terminal = try Self.page(
      ["pagenumber": String(Int.max), "pagesize": "1", "total": String(Int.max)], count: 1)
    #expect(try ParkEventQuery(pageNumber: Int.max, pageSize: 1).next(after: terminal) == nil)
  }

  private static func page(_ metadata: [String: String], count: Int) throws -> ParkEventCollection {
    var object: [String: Any] = metadata
    object["errors"] = []
    object["data"] = Array(repeating: ["id": "one", "title": "An event"], count: count)
    return try JSONDecoder().decode(
      ParkEventCollection.self, from: JSONSerialization.data(withJSONObject: object))
  }
}
