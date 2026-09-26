import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Event models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkEventTests {
  @Test(
    "All recorded successful event responses round trip",
    arguments: [
      Fixture.eventsBeyond, .eventsCancellation, .eventsEmpty, .eventsExpanded,
      .eventsExpandedEmpty, .eventsFullTerminal, .eventsPageFirst, .eventsPageLast,
      .eventsRecurring, .eventsSearch,
    ])
  func allRecordedSuccessfulEventResponsesRoundTrip(_ fixture: Fixture) throws {
    let value = try JSONDecoder().decode(ParkEventCollection.self, from: fixture.data())
    let encoded = try JSONEncoder().encode(value)
    #expect(try JSONDecoder().decode(ParkEventCollection.self, from: encoded) == value)
  }

  @Test("Cancellation and missing values preserve provider distinctions")
  func cancellationAndMissingValuesPreserveProviderDistinctions() throws {
    let response = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsCancellation.data())
    let event = try #require(response.data.first)
    #expect(event.cancelledDates == ["09/13/2026"])
    #expect(event.date == "2026-09-13")
    #expect(event.dates == [])
    let minimal = Data(#"{"id":"one","title":"An event","datetimeupdated":null}"#.utf8)
    let decoded = try JSONDecoder().decode(ParkEvent.self, from: minimal)
    #expect(decoded.dateTimeUpdated == nil)
    #expect(decoded.images == nil)
    #expect(decoded.tags == nil)
  }

  @Test("Expanded responses preserve repeated identifiers without metadata")
  func expandedResponsesPreserveRepeatedIdentifiersWithoutMetadata() throws {
    let response = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsExpanded.data())
    #expect(response.page == nil)
    #expect(response.data.count == 6)
    #expect(Set(response.data.map(\.id)) == ["29B71501-9354-F7EC-6621568238F935A9"])
    #expect(
      response.data.map(\.date) == [
        "2026-09-28", "2026-09-29", "2026-09-30", "2026-10-01", "2026-10-02", "2026-10-03",
      ])
    #expect(response.data.first?.dates?.count == 5)
  }

  @Test("Recorded event fields retain exact wire values")
  func recordedEventFieldsRetainExactWireValues() throws {
    let response = try JSONDecoder().decode(
      ParkEventCollection.self, from: Fixture.eventsPageFirst.data())
    let page = try #require(response.page)
    #expect(page.pageNumber == "1")
    #expect(page.pageSize == "2")
    #expect(page.total == "3")
    #expect(page.errors.isEmpty)
    let event = try #require(page.data.first)
    #expect(event.id == "C8CB2CEE-988B-0E9F-B658C9A05128868D")
    #expect(event.title == "Ranger Program (Canyon Area) - Artist Point Talk")
    #expect(event.eventID == "134460")
    #expect(event.categoryID == "1")
    #expect(event.latitude == "45.000000")
    #expect(event.longitude == "-110.000000")
    #expect(event.isRecurring == "true")
    #expect(event.isAllDay == "false")
    #expect(event.isFree == "true")
    #expect(event.isRegistrationRequired == "false")
    #expect(event.dateTimeCreated == "2026-06-09T14:35:51.983")
    #expect(event.description?.hasPrefix("<p>From a classic viewpoint") == true)
    #expect(event.siteCode == "yell")
    #expect(event.parkFullName == "Yellowstone National Park")
    #expect(event.times?.first?.timeStart == "02:00 PM")
    #expect(event.times?.first?.sunriseStart == "false")
    #expect(event.images?.first?.path?.hasPrefix("/common/uploads/event_calendar/") == true)
    #expect(event.images?.first?.url == event.images?.first?.path)
    #expect(event.images?.first?.ordinal == "1")
  }

  @Test("Unknown error entries retain every JSON value kind")
  func unknownErrorEntriesRetainEveryJSONValueKind() throws {
    let data = Data(
      #"{"data":[],"errors":[{"code":"future","detail":[null,true,123.5]}],"pagenumber":"1","pagesize":"10","total":"0"}"#
        .utf8)
    let response = try JSONDecoder().decode(ParkEventCollection.self, from: data)
    #expect(
      response.page?.errors == [
        .object([
          "code": .string("future"),
          "detail": .array([.null, .boolean(true), .number(Decimal(string: "123.5") ?? 0)]),
        ])
      ])
    #expect(
      try JSONDecoder().decode(ParkEventCollection.self, from: JSONEncoder().encode(response))
        == response)
  }
}
