import Foundation
import SwiftNPSDataTestSupport
import SwiftNPSVisitationModels
import Testing

@Suite("Visitation models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct VisitationModelTests {
  @Test("Empty visitation remains empty")
  func emptyVisitationRemainsEmpty() throws {
    let rows = try JSONDecoder().decode(
      [NPSVisitationRecord].self, from: IRMAFixture.visitationEmpty.data())
    #expect(rows.isEmpty)
  }

  @Test("Sparse months remain absent instead of becoming zero")
  func sparseMonthsRemainAbsentInsteadOfBecomingZero() throws {
    let rows = try JSONDecoder().decode(
      [NPSVisitationRecord].self, from: IRMAFixture.visitationSparse.data())
    #expect(rows.map(\.month) == [11, 12])
    #expect(rows.map(\.year) == [2025, 2025])
    #expect(rows.map(\.recreationVisitors) == [68005, 11980])
  }

  @Test("Unexpected response months and large counts are preserved")
  func unexpectedResponseMonthsAndLargeCountsArePreserved() throws {
    let data = Data(
      #"{"Month":13,"Year":0,"RecreationVisitors":4000000000,"NonRecreationVisitors":-1,"UnitCode":null,"UnitName":null}"#
        .utf8)
    let row = try JSONDecoder().decode(NPSVisitationRecord.self, from: data)
    #expect(row.month == 13)
    #expect(row.recreationVisitors == 4_000_000_000)
    #expect(row.nonRecreationVisitors == -1)
    #expect(row.year == 0)
  }
}
