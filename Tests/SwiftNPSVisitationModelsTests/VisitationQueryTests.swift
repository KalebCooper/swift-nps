import SwiftNPSDataTestSupport
import SwiftNPSVisitationModels
import Testing

@Suite("Visitation queries", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct VisitationQueryTests {
  @Test("Cross year ranges preserve exact code order and spelling")
  func crossYearRangesPreserveExactCodeOrderAndSpelling() throws {
    let query = try VisitationQuery(
      end: .init(year: 2026, month: 2), start: .init(year: 2025, month: 11),
      unitCodes: ["Acad", "YELL"])
    #expect(
      VisitationEndpoint.visitation(query: query).path
        == "/visitation?endMonth=2&endYear=2026&format=json&startMonth=11&startYear=2025&unitCodes=Acad,YELL"
    )
  }

  @Test(
    "Empty and unsafe unit lists fail locally",
    arguments: [[], [""], ["ACAD,YELL"], ["ACAD\n"], [" ACAD"]])
  func emptyAndUnsafeUnitListsFailLocally(_ codes: [String]) throws {
    let month = try VisitationMonth(year: 2025, month: 1)
    #expect(throws: VisitationQuery.ValidationError.self) {
      try VisitationQuery(end: month, start: month, unitCodes: codes)
    }
  }

  @Test(
    "Invalid months and years fail locally", arguments: [(2025, 0), (2025, 13), (0, 1), (-1, 1)])
  func invalidMonthsAndYearsFailLocally(_ year: Int, _ month: Int) {
    #expect(throws: VisitationMonth.ValidationError.self) {
      try VisitationMonth(year: year, month: month)
    }
  }

  @Test("Reserved Unicode and repeated codes retain exact serialization")
  func reservedUnicodeAndRepeatedCodesRetainExactSerialization() throws {
    let month = try VisitationMonth(year: 2025, month: 1)
    let query = try VisitationQuery(
      end: month, start: month, unitCodes: ["A&B", "+%", "é", "A&B"])
    #expect(
      VisitationEndpoint.visitation(query: query).path
        == "/visitation?endMonth=1&endYear=2025&format=json&startMonth=1&startYear=2025&unitCodes=A%26B,%2B%25,%C3%A9,A%26B"
    )
  }

  @Test("Reversed ranges fail locally")
  func reversedRangesFailLocally() throws {
    let start = try VisitationMonth(year: 2025, month: 2)
    let end = try VisitationMonth(year: 2025, month: 1)
    #expect(throws: VisitationQuery.ValidationError.reversedRange) {
      try VisitationQuery(end: end, start: start, unitCodes: ["ACAD"])
    }
  }
}
