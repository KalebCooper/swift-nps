import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Alert models", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ParkAlertTests {
  @Test("Constructed related road events decode with nulls and unknown fields")
  func constructedRelatedRoadEventsDecodeWithNullsAndUnknownFields() throws {
    // Constructed, not recorded: every recorded alert has an empty relatedRoadEvents array.
    let json = Data(
      #"""
      {"id":"A1","title":"Road work","url":null,"parkCode":null,"description":null,
      "category":"Caution","lastIndexedDate":null,"futureField":{"nested":true},
      "relatedRoadEvents":[{"title":"Night closures","id":"E1","type":"roadevent",
      "url":"https://www.nps.gov/yell/planyourvisit/parkroads.htm","extra":1},
      {"title":null,"id":"E2"}]}
      """#.utf8)
    let alert = try JSONDecoder().decode(ParkAlert.self, from: json)
    #expect(alert.id == "A1")
    #expect(alert.title == "Road work")
    #expect(alert.url == nil)
    #expect(alert.parkCode == nil)
    #expect(alert.description == nil)
    #expect(alert.lastIndexedDate == nil)
    let events = try #require(alert.relatedRoadEvents)
    #expect(events.count == 2)
    #expect(events[0].id == "E1")
    #expect(events[0].title == "Night closures")
    #expect(events[0].type == "roadevent")
    #expect(events[0].url == "https://www.nps.gov/yell/planyourvisit/parkroads.htm")
    #expect(events[1].id == "E2")
    #expect(events[1].title == nil)
    #expect(events[1].type == nil)
    #expect(events[1].url == nil)
  }

  @Test("Missing identity or title fails to decode")
  func missingIdentityOrTitleFailsToDecode() {
    // Constructed, not recorded: NPS alerts always carry an id and title.
    for body in [#"{"title":"Closure"}"#, #"{"id":"A1"}"#] {
      #expect(throws: DecodingError.self) {
        try JSONDecoder().decode(ParkAlert.self, from: Data(body.utf8))
      }
    }
  }

  @Test("Recorded alert pages decode with their envelopes")
  func recordedAlertPagesDecodeWithTheirEnvelopes() throws {
    let first = try decode(.alertsPageFirst)
    #expect(first.total == "4")
    #expect(first.limit == "1")
    #expect(first.start == "0")
    #expect(first.data.map(\.id) == ["D3E90E5C-ABED-4EDD-B17F-7D4744770978"])
    let last = try decode(.alertsPageLast)
    #expect(last.start == "1")
    #expect(last.data.map(\.id) == ["F8AFCEAD-7E34-4C99-8AF6-C0B7C376C8FB"])
    #expect(
      last.data.first?.title == "Eastern Section of Beech Mountain Loop Road Closed for Repairs")
    #expect(last.data.first?.lastIndexedDate == "2026-08-24 00:00:00.0")
    let empty = try decode(.alertsEmpty)
    #expect(empty.total == "0")
    #expect(empty.data.isEmpty)
  }

  @Test("Recorded search results preserve provider values")
  func recordedSearchResultsPreserveProviderValues() throws {
    let page = try decode(.alertsSearch)
    #expect(page.total == "9")
    #expect(page.limit == "2")
    #expect(page.data.count == 2)
    let acadia = page.data[0]
    #expect(acadia.id == "D3E90E5C-ABED-4EDD-B17F-7D4744770978")
    #expect(acadia.title == "Southern Section of Ocean Path Closed for Repairs")
    #expect(acadia.url == "")
    #expect(acadia.parkCode == "acad")
    #expect(acadia.category == "Park Closure")
    #expect(acadia.relatedRoadEvents == [])
    #expect(acadia.lastIndexedDate == "2026-09-16 00:00:00.0")
    #expect(acadia.description?.hasPrefix("Starting Aug 31, a section of Ocean Path") == true)
    let yellowstone = page.data[1]
    #expect(yellowstone.id == "00D47802-8E06-4418-80D8-69D37A885146")
    #expect(yellowstone.title == "West Thumb Geyser Basin Boardwalk - Partial Closure")
    #expect(yellowstone.url == "https://www.nps.gov/yell/images/WT-Desk-Ref-Map-closure.jpg")
    #expect(yellowstone.parkCode == "yell")
    #expect(yellowstone.category == "Information")
    #expect(yellowstone.relatedRoadEvents == [])
    #expect(yellowstone.lastIndexedDate == "2026-09-14 00:00:00.0")
  }

  private func decode(_ fixture: Fixture) throws -> NPSCollection<ParkAlert> {
    try JSONDecoder().decode(NPSCollection<ParkAlert>.self, from: fixture.data())
  }
}
