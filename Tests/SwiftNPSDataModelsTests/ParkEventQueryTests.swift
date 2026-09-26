import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Event queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkEventQueryTests {
  @Test("All event filters encode in deterministic name order")
  func allEventFiltersEncodeInDeterministicNameOrder() throws {
    let query = try ParkEventQuery(
      dateEnd: .init("2026-10-07"), dateStart: .init("2026-10-01"),
      eventTypes: ["Talk", "Walk"], expandRecurring: true, identifier: "A +&/#?é",
      organizations: ["im", "X"], pageNumber: 3, pageSize: 2,
      parkCodes: [ParkCode("YELL"), ParkCode("acad")], portals: ["parks", "X"],
      searchText: "a +&/#?é", stateCodes: [StateCode("wy"), StateCode("ME")],
      tagsAll: ["one", "two"], tagsNone: ["none"], tagsOne: ["x,y", "z"])
    #expect(
      Endpoint.parkEvents(query: query).path
        == "/events?dateEnd=2026-10-07&dateStart=2026-10-01&eventType=Talk,Walk&expandRecurring=true&id=A%20%2B%26%2F%23%3F%C3%A9&organization=im,X&pageNumber=3&pageSize=2&parkCode=YELL,acad&portal=parks,X&q=a%20%2B%26%2F%23%3F%C3%A9&stateCode=wy,ME&tagsAll=one,two&tagsNone=none&tagsOne=x%2Cy,z"
    )
    #expect(query.queryItems.map(\.name) == query.queryItems.map(\.name).sorted())
    #expect(Set([query, query]).count == 1)
    #expect(query != (try ParkEventQuery()))
  }

  @Test("Default and empty event filters remain explicit")
  func defaultAndEmptyEventFiltersRemainExplicit() throws {
    #expect(
      try Endpoint.parkEvents(query: ParkEventQuery()).path
        == "/events?expandRecurring=false&pageNumber=1&pageSize=10")
    #expect(
      try Endpoint.parkEvents(query: ParkEventQuery(identifier: "", searchText: "")).path
        == "/events?expandRecurring=false&id=&pageNumber=1&pageSize=10&q=")
  }

  @Test(
    "Gregorian calendar validation rejects invalid syntax and dates",
    arguments: [
      "", "0000-01-01", "1900-02-29", "2026-02-29", "2026-04-31", "2026-00-01",
      "2026-13-01", "2026-01-00", "2026-1-01", "2026-01-1", "2026/01/01",
      "２０２６-01-01", "2026-01-01 ", "2026-01-01T00:00:00Z",
    ])
  func gregorianCalendarValidationRejectsInvalidSyntaxAndDates(_ value: String) {
    #expect(throws: ParkEventQuery.ValidationError.invalidDate) {
      try ParkEventQuery.CalendarDate(value)
    }
  }

  @Test(
    "Gregorian calendar validation retains valid boundary dates",
    arguments: [
      "0001-01-01", "2000-02-29", "2024-02-29", "2026-02-28", "9999-12-31",
    ])
  func gregorianCalendarValidationRetainsValidBoundaryDates(_ value: String) throws {
    #expect(try ParkEventQuery.CalendarDate(value).rawValue == value)
  }

  @Test("Invalid event pagination and reversed ranges fail locally")
  func invalidEventPaginationAndReversedRangesFailLocally() throws {
    for value in [0, -1, Int.min] {
      #expect(throws: ParkEventQuery.ValidationError.invalidPageNumber) {
        try ParkEventQuery(pageNumber: value)
      }
    }
    for value in [0, -1, 51, Int.max] {
      #expect(throws: ParkEventQuery.ValidationError.invalidPageSize) {
        try ParkEventQuery(pageSize: value)
      }
    }
    #expect(throws: ParkEventQuery.ValidationError.reversedDateRange) {
      try ParkEventQuery(dateEnd: .init("2026-10-01"), dateStart: .init("2026-10-02"))
    }
    _ = try ParkEventQuery(
      dateEnd: .init("2026-10-01"), dateStart: .init("2026-10-01"), pageSize: 50)
    _ = try ParkEventQuery(pageNumber: Int.max)
  }
}
