import Foundation
import SwiftNPSDataModels
import SwiftNPSDataTestSupport
import Testing

@Suite("Activities", .timeLimit(.minutes(suiteTimeLimitMinutes)))
struct ActivityTests {
  @Test("The recorded search page decodes every activity field as sent")
  func theRecordedSearchPageDecodesEveryActivityFieldAsSent() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<Activity>.self, from: Fixture.activitiesSearch.data())
    #expect(page.total == "1")
    #expect(page.limit == "2")
    #expect(page.start == "0")
    let activity = try #require(page.data.first)
    #expect(page.data.count == 1)
    #expect(activity.id == "B33DC9B6-0B7D-4322-BAD7-A13A34C584A3")
    #expect(activity.name == "Guided Tours")
  }

  @Test("The recorded pages advance through the requested identifiers")
  func theRecordedPagesAdvanceThroughTheRequestedIdentifiers() throws {
    let first = try JSONDecoder().decode(
      NPSCollection<Activity>.self, from: Fixture.activitiesPageFirst.data())
    let last = try JSONDecoder().decode(
      NPSCollection<Activity>.self, from: Fixture.activitiesPageLast.data())
    #expect(first.total == "2")
    #expect(first.start == "0")
    #expect(last.start == "1")
    #expect(first.data.map(\.name) == ["Wildlife Watching"])
    #expect(last.data.map(\.name) == ["Fishing"])
    #expect(last.data.first?.id == "AE42B46C-E4B7-4889-A122-08FE180371AE")
  }

  @Test("The recorded empty page decodes with no activities")
  func theRecordedEmptyPageDecodesWithNoActivities() throws {
    let page = try JSONDecoder().decode(
      NPSCollection<Activity>.self, from: Fixture.activitiesEmpty.data())
    #expect(page.total == "0")
    #expect(page.data.isEmpty)
  }

  @Test("An activity decodes its identifier and name as sent")
  func anActivityDecodesItsIdentifierAndNameAsSent() throws {
    let activity = try JSONDecoder().decode(
      Activity.self, from: Data(#"{"id":"A1","name":"Hiking"}"#.utf8))
    #expect(activity.id == "A1")
    #expect(activity.name == "Hiking")
  }
}
