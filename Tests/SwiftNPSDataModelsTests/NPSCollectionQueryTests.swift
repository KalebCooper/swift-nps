import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Collection continuation", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct NPSCollectionQueryTests {
  @Test(
    "Invalid pagination metadata fails explicitly",
    arguments: [
      ("limit", "0"), ("limit", "-1"), ("start", "+0"), ("total", ""),
      ("total", "1.5"), ("total", " 2"), ("total", "999999999999999999999999999"),
    ])
  func invalidPaginationMetadataFailsExplicitly(_ field: String, _ value: String) throws {
    let page = try modifiedPage([field: value])
    #expect(throws: NPSPaginationError.invalidMetadata(field: field, value: value)) {
      try ParkQuery(limit: 1).next(after: page)
    }
  }

  @Test("Offset overflow is reported without wrapping")
  func offsetOverflowIsReportedWithoutWrapping() throws {
    let page = try modifiedPage(["start": String(Int.max), "total": String(Int.max)])
    #expect(throws: NPSPaginationError.offsetOverflow) {
      try ParkQuery(start: Int.max).next(after: page)
    }
  }

  @Test("Recorded alert pages advance without changing query options")
  func recordedAlertPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<ParkAlert>.self, from: Fixture.alertsPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<ParkAlert>.self, from: Fixture.alertsPageLast.data())
    let empty = try JSONDecoder().decode(
      NPSCollection<ParkAlert>.self, from: Fixture.alertsEmpty.data())
    let query = try AlertQuery(
      limit: 1, parkCodes: [ParkCode("acad")], searchText: "closure", stateCodes: [StateCode("ME")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "closure")
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last)?.start == 2)
    #expect(try AlertQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Recorded pages advance without changing query options")
  func recordedPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksPageLast.data())
    let query = try ParkQuery(
      limit: 1, parkCodes: [ParkCode("acad"), ParkCode("yell")], searchText: "park",
      sort: [.ascending("parkCode")], stateCodes: [StateCode("ME"), StateCode("WY")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "park")
    #expect(following.sort == [.ascending("parkCode")])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last) == nil)
    let beyond = try JSONDecoder().decode(
      NPSCollection<Park>.self, from: Fixture.parksBeyond.data())
    #expect(try ParkQuery(start: 2).next(after: beyond) == nil)
  }

  @Test("Recorded visitor center pages advance without changing query options")
  func recordedVisitorCenterPagesAdvanceWithoutChangingQueryOptions() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersPageLast.data())
    let empty = try JSONDecoder().decode(
      NPSCollection<VisitorCenter>.self, from: Fixture.visitorCentersEmpty.data())
    let query = try VisitorCenterQuery(
      limit: 1, parkCodes: [ParkCode("acad")], searchText: "center", sort: [.ascending("name")],
      stateCodes: [StateCode("ME")])
    let following = try #require(try query.next(after: first))
    #expect(following.start == 1)
    #expect(following.limit == 1)
    #expect(following.parkCodes == query.parkCodes)
    #expect(following.searchText == "center")
    #expect(following.sort == [.ascending("name")])
    #expect(following.stateCodes == query.stateCodes)
    #expect(try following.next(after: last)?.start == 2)
    #expect(try VisitorCenterQuery(limit: 1).next(after: empty) == nil)
  }

  @Test("Short pages advance by returned count without skipping records")
  func shortPagesAdvanceByReturnedCountWithoutSkippingRecords() throws {
    let page = try modifiedPage(["limit": "50", "total": "3"])
    #expect(try ParkQuery().next(after: page)?.start == 1)
  }

  @Test("Unexpected offsets and contradictory counts cannot imply completion")
  func unexpectedOffsetsAndContradictoryCountsCannotImplyCompletion() throws {
    let repeated = try modifiedPage([:])
    #expect(throws: NPSPaginationError.unexpectedStart(actual: 0, expected: 1)) {
      try ParkQuery(start: 1).next(after: repeated)
    }
    let premature = try modifiedPage(["data": []])
    #expect(throws: NPSPaginationError.inconsistentPage) { try ParkQuery().next(after: premature) }
    let contradictory = try modifiedPage(["total": "0"])
    #expect(throws: NPSPaginationError.inconsistentPage) {
      try ParkQuery().next(after: contradictory)
    }
  }

  private func modifiedPage(_ changes: [String: Any]) throws -> NPSCollection<Park> {
    // Constructed metadata cases are deliberately separate from the recorded response bodies.
    var object = try #require(
      JSONSerialization.jsonObject(with: Fixture.parksPageFirst.data()) as? [String: Any])
    object.merge(changes) { _, new in new }
    return try JSONDecoder().decode(
      NPSCollection<Park>.self, from: JSONSerialization.data(withJSONObject: object))
  }
}
