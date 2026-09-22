import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Activity parks", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ActivityParksTests {
  @Test("The recorded search page decodes every activity and park field as sent")
  func theRecordedSearchPageDecodesEveryActivityAndParkFieldAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ActivityParks>.self, from: Fixture.activityParksSearch.data())
    #expect(page.total == "1")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    let activity = try #require(page.data.first)
    #expect(page.data.count == 1)
    #expect(activity.id == "B33DC9B6-0B7D-4322-BAD7-A13A34C584A3")
    #expect(activity.name == "Guided Tours")
    let parks = try #require(activity.parks)
    #expect(parks.map(\.parkCode) == ["cwdw", "drto"])
    let defenses = try #require(parks.first)
    #expect(defenses.designation == "")
    #expect(defenses.fullName == "Civil War Defenses of Washington")
    #expect(defenses.name == "Civil War Defenses of Washington")
    #expect(defenses.states == "DC,MD,VA")
    #expect(defenses.url == "https://www.nps.gov/cwdw/index.htm")
    let tortugas = try #require(parks.last)
    #expect(tortugas.designation == "National Park")
    #expect(tortugas.fullName == "Dry Tortugas National Park")
    #expect(tortugas.name == "Dry Tortugas")
    #expect(tortugas.states == "FL")
    #expect(tortugas.url == "https://www.nps.gov/drto/index.htm")
  }

  @Test("The recorded pages narrow each activity to the requested park")
  func theRecordedPagesNarrowEachActivityToTheRequestedPark() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<ActivityParks>.self, from: Fixture.activityParksPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<ActivityParks>.self, from: Fixture.activityParksPageLast.data())
    #expect(first.total == "2")
    #expect(first.start == "0")
    #expect(last.start == "1")
    #expect(first.data.map(\.name) == ["Wildlife Watching"])
    #expect(last.data.map(\.name) == ["Fishing"])
    #expect(last.data.first?.id == "AE42B46C-E4B7-4889-A122-08FE180371AE")
    for activity in first.data + last.data {
      #expect(activity.parks?.map(\.parkCode) == ["drto"])
    }
  }

  @Test("The recorded empty page decodes with no activities")
  func theRecordedEmptyPageDecodesWithNoActivities() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<ActivityParks>.self, from: Fixture.activityParksEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }

  @Test(
    "A missing or null parks array decodes as nil",
    arguments: [#"{"id":"A1","name":"Hiking"}"#, #"{"id":"A1","name":"Hiking","parks":null}"#])
  func aMissingOrNullParksArrayDecodesAsNil(_ json: String) throws {
    let activity = try JSONDecoder().decode(ActivityParks.self, from: Data(json.utf8))
    #expect(activity.id == "A1")
    #expect(activity.name == "Hiking")
    #expect(activity.parks == nil)
  }
}
